use std::collections::HashMap;
use std::ops::Deref;
use wgpu::PresentMode;
use digital_signage_api::{LayerId, Screen, SlideLayer};
use crate::image_cache::ImageCache;
use crate::renderer::pipeline::image_renderer::WgpuImageRenderer;
use crate::renderer::pipeline::text_renderer::WgpuTextRenderer;
use crate::renderer::slides_state::SlidesState;

pub struct WindowRenderer {
    surface: wgpu::Surface<'static>,
    surface_config: wgpu::SurfaceConfiguration,
    renderer: WgpuImageRenderer,
    text_renderer: HashMap<LayerId, WgpuTextRenderer>,
    slides_state: SlidesState,
}

impl WindowRenderer {
    pub fn new(surface: wgpu::Surface<'static>, window: &winit::window::Window, device: &wgpu::Device, adapter: &wgpu::Adapter) -> color_eyre::Result<Self> {
        let surface_caps = surface.get_capabilities(adapter);
        let surface_format = surface_caps
            .formats
            .iter()
            .copied()
            .find(|f| f.is_srgb())
            .unwrap_or(surface_caps.formats[0]);
        let config = wgpu::SurfaceConfiguration {
            usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
            format: surface_format,
            width: window.inner_size().width,
            height: window.inner_size().height,
            present_mode: PresentMode::Immediate,
            alpha_mode: surface_caps.alpha_modes[0],
            view_formats: vec![],
            desired_maximum_frame_latency: 2,
        };
        surface.configure(device, &config);
        
        let renderer = WgpuImageRenderer::new(device, (1920, 1080))?;
        let slides_state = SlidesState::new();
        slides_state.spawn_timer();
        
        Ok(Self { renderer, text_renderer: Default::default(), surface, surface_config: config, slides_state })
    }
    
    pub fn resize(&mut self, device: &wgpu::Device, width: u32, height: u32) {
        self.surface_config.width = width;
        self.surface_config.height = height;
        self.surface.configure(device, &self.surface_config);
    }

    pub fn render(&mut self, device: &wgpu::Device, queue: &wgpu::Queue, config: &Screen, image_cache: &ImageCache) -> color_eyre::Result<()> {
        let current_slide = self.slides_state.get_current_slide(config);
        if let Some(slide) = current_slide {
            tracing::info!("Rendering slide {}", &slide.name);
            let texture = self.surface.get_current_texture()?;
            let view = texture
                .texture
                .create_view(&wgpu::TextureViewDescriptor::default());
            let mut command_buffers = Vec::with_capacity(slide.layers.len());
            for layer in &slide.layers {
                match layer {
                    SlideLayer::Text(text) => {
                        if self.text_renderer.get(&text.id).is_none() {
                            self.text_renderer.insert(text.id, WgpuTextRenderer::new(device, queue));
                        }
                        if let Some(text_renderer) = self.text_renderer.get_mut(&text.id) {
                            text_renderer.draw_text(device, queue, text)?;
                            command_buffers.push(text_renderer.render(device, &view)?);
                        }
                    }
                    SlideLayer::Image(image) => {
                        if let Some(image) = image_cache.get_image(&image.id) {
                            command_buffers.push(self.renderer.render(&view, device, queue, image.deref())?);
                        }
                    }
                }
            }
            queue.submit(command_buffers);
            texture.present();
            // self.text_renderer.cleanup();
        }
        Ok(())
    }
    
    pub fn take_has_transitioned(&self) -> bool {
        self.slides_state.take_has_transitioned()
    }
}