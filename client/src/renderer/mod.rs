use std::collections::HashMap;
use std::sync::mpsc::Receiver;
use winit::event::{Event, WindowEvent};
use winit::event_loop::{ControlFlow, EventLoop, EventLoopWindowTarget};
use winit::window::{Fullscreen, Window, WindowBuilder, WindowId};

use digital_signage_api::{Device, DeviceMonitorInfo, Screen};
use crate::config_store::ConfigStore;
use crate::image_cache::ImageCache;
use crate::renderer::window::WindowRenderer;

mod window;
mod pipeline;
mod slides_state;

pub struct Renderer {
    event_loop: EventLoop<()>,
    renderer: WgpuRenderer,
}

struct WgpuRenderer {
    instance: wgpu::Instance,
    adapter: wgpu::Adapter,
    device: wgpu::Device,
    queue: wgpu::Queue,
    windows: HashMap<String, Window>,
    window_renderers: HashMap<WindowId, WindowRenderer>,
    image_cache: ImageCache,
    images_cached: Receiver<()>,
}

impl Renderer {
    pub async fn new(image_cache: ImageCache, images_cached: Receiver<()>) -> color_eyre::Result<Self> {
        let instance = wgpu::Instance::new(wgpu::InstanceDescriptor {
            backends: wgpu::Backends::VULKAN | wgpu::Backends::METAL | wgpu::Backends::DX12,
            ..Default::default()
        });

        let adapter = instance
            .request_adapter(&wgpu::RequestAdapterOptions {
                force_fallback_adapter: false,
                compatible_surface: None,
                power_preference: wgpu::PowerPreference::HighPerformance,
            })
            .await
            .ok_or_else(|| color_eyre::eyre::eyre!("No compatible video adapter available"))?;
        let (device, queue) = adapter
            .request_device(
                &wgpu::DeviceDescriptor {
                    required_limits: wgpu::Limits::downlevel_defaults(),
                    ..Default::default()
                },
                None,
            )
            .await?;

        let renderer = WgpuRenderer {
            instance,
            adapter,
            device,
            queue,
            windows: Default::default(),
            window_renderers: Default::default(),
            image_cache,
            images_cached,
        };

        Ok(Self {
            event_loop: EventLoop::new()?,
            renderer,
        })
    }

    pub fn get_monitors(&self) -> Vec<DeviceMonitorInfo> {
        let monitors = self.event_loop.available_monitors()
            .map(|monitor| DeviceMonitorInfo {
                identifier: monitor.name().unwrap_or_default(),
                width: monitor.size().width,
                height: monitor.size().height,
            }).collect();

        monitors
    }

    pub fn run(mut self, config_store: ConfigStore) -> color_eyre::Result<()> {
        self.event_loop.run(|event, target| {
            target.set_control_flow(ControlFlow::Poll);
            let window_configs = self.renderer.prepare(&config_store, target);
            match event {
                Event::WindowEvent {
                    event: WindowEvent::RedrawRequested,
                    window_id
                } => {
                    self.renderer.render(&window_configs, window_id);
                }
                Event::WindowEvent {
                    event: WindowEvent::Resized(size),
                    window_id
                } => {
                    if size.width > 0 && size.height > 0 {
                        self.renderer.resize(window_id, size.width, size.height);
                    }
                    self.renderer.render(&window_configs, window_id);
                }
                _ => {}
            }
        })?;

        Ok(())
    }
}

impl WgpuRenderer {
    fn prepare(&mut self, config_store: &ConfigStore, target: &EventLoopWindowTarget<()>) -> HashMap<WindowId, Screen> {
        let config = config_store.get_changed();
        let mut window_configs = HashMap::new();
        if let (Some(config), has_changed) = config {
            self.image_cache.load_images(&config);
            let has_updated_images = self.images_cached.try_recv().is_ok();
            if let Err(err) = self.create_windows(target, &config) {
                tracing::error!(error = ?err, "Error creating windows");
            }
            for (window, config) in config.monitors.into_iter().filter_map(|monitor| {
                let window = self.windows.get(&monitor.identifier)?;
                let screen = monitor.screen?;

                Some((window, screen))
            }) {
                window_configs.insert(window.id(), config);
                let has_transitioned = if let Some(renderer) = self.window_renderers.get(&window.id()) {
                    renderer.take_has_transitioned()
                }else {
                    false
                };
                if has_changed || has_updated_images || has_transitioned {
                    tracing::debug!("Has changed config: {has_changed}, has updated images: {has_updated_images}, has transitioned: {has_transitioned}");
                    window.request_redraw();
                }
            }
        }

        window_configs
    }

    fn render(&mut self, window_configs: &HashMap<WindowId, Screen>, window_id: WindowId) {
        if let Some(renderer) = self.window_renderers.get_mut(&window_id) {
            if let Some(config) = window_configs.get(&window_id) {
                tracing::debug!("Rendering window {window_id:?}");
                if let Err(err) = renderer.render(&self.device, &self.queue, config, &self.image_cache) {
                    tracing::error!(error = ?err, "Error rendering window");
                }
            }
        }
    }

    fn resize(&mut self, window_id: WindowId, width: u32, height: u32) {
        if let Some(renderer) = self.window_renderers.get_mut(&window_id) {
            renderer.resize(&self.device, width, height);
        }
    }

    fn create_windows(&mut self, target: &EventLoopWindowTarget<()>, config: &Device) -> color_eyre::Result<()> {
        for device_monitor in config.monitors.iter()
            .filter(|monitor| monitor.screen.is_some()) {
            if self.windows.contains_key(&device_monitor.identifier) {
                continue;
            }
            let Some(monitor) = target.available_monitors().find(|m| m.name().as_ref() == Some(&device_monitor.identifier)) else {
                continue;
            };
            let window = if let Ok(window) = WindowBuilder::new()
                .with_fullscreen(Some(Fullscreen::Borderless(Some(monitor.clone()))))
                .build(target)
            {
                window
            } else {
                match WindowBuilder::new().build(target) {
                    Err(err) => {
                        tracing::error!(error = ?err, "Error creating window");
                        continue;
                    }
                    Ok(window) => window
                }
            };

            window.set_title(&format!(
                "Digital Signage ({})",
                monitor.name().unwrap_or_default()
            ));
            window.set_cursor_visible(false);
            let surface = unsafe {
                self.instance.create_surface_unsafe(wgpu::SurfaceTargetUnsafe::from_window(&window)?)
            }?;
            self.window_renderers.insert(window.id(), WindowRenderer::new(surface, &window, &self.device, &self.adapter)?);
            self.windows.insert(device_monitor.identifier.clone(), window);
        }

        Ok(())
    }
}

