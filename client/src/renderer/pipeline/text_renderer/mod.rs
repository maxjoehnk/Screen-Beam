use glyphon::{Attrs, Buffer, Family, FontSystem, Metrics, Resolution, Shaping, SwashCache, TextArea, TextAtlas, TextBounds, TextRenderer, Viewport, Weight};
use glyphon::cosmic_text::Align;
use wgpu::{CommandBuffer, MultisampleState};
use digital_signage_api::{TextAlignment, TextLayer};

pub struct WgpuTextRenderer {
    font_system: FontSystem,
    swash_cache: SwashCache,
    atlas: TextAtlas,
    text_renderer: TextRenderer,
    buffer: Buffer,
    viewport: Viewport,
}

impl WgpuTextRenderer {
    pub fn new(device: &wgpu::Device, queue: &wgpu::Queue) -> Self {
        let mut font_system = FontSystem::new();
        let swash_cache = SwashCache::new();
        let cache = glyphon::Cache::new(device);
        let mut viewport = Viewport::new(device, &cache);
        viewport.update(queue, Resolution {
            width: 1920,
            height: 1080,
        });
        let mut atlas = TextAtlas::new(
            device,
            queue,
            &cache,
            wgpu::TextureFormat::Bgra8UnormSrgb,
        );
        let text_renderer = TextRenderer::new(
            &mut atlas,
            device,
            MultisampleState::default(),
            None,
        );
        let mut buffer = Buffer::new(&mut font_system, Metrics::new(32.0, 32.0));
        buffer.set_size(&mut font_system, Some(1920f32), Some(1080f32));
        buffer.shape_until_scroll(&mut font_system, true);

        Self {
            font_system,
            swash_cache,
            viewport,
            atlas,
            text_renderer,
            buffer,
        }
    }

    pub fn draw_text(&mut self, device: &wgpu::Device, queue: &wgpu::Queue, text: &TextLayer) -> color_eyre::Result<()> {
        self.buffer.set_metrics(
            &mut self.font_system,
            Metrics::new(text.font_size as f32, text.line_height.unwrap_or(text.font_size) as f32),
        );
        let align = Self::map_alignment(text.alignment);
        let color = glyphon::Color::rgba(text.color.red, text.color.green, text.color.blue, text.color.alpha);
        self.buffer.set_text(
            &mut self.font_system,
            &text.text,
            Self::map_attrs(text),
            Shaping::Advanced,
        );
        for line in self.buffer.lines.iter_mut() {
            line.set_align(Some(align));
        }
        self.buffer.shape_until_scroll(&mut self.font_system, true);
        let mut text_areas = vec![TextArea {
            buffer: &self.buffer,
            left: text.x as f32,
            top: text.y as f32,
            scale: 1.0,
            bounds: TextBounds::default(),
            default_color: color,
            custom_glyphs: &[],
        }];
        if let Some(shadow) = text.shadow {
            let shadow_color = glyphon::Color::rgba(shadow.color.red, shadow.color.green, shadow.color.blue, shadow.color.alpha);
            text_areas.insert(0, TextArea {
                buffer: &self.buffer,
                left: text.x as f32 + shadow.x_offset as f32,
                top: text.y as f32 + shadow.y_offset as f32,
                scale: 1.0,
                bounds: TextBounds::default(),
                default_color: shadow_color,
                custom_glyphs: &[],
            });
        }
        self.text_renderer.prepare(
            device,
            queue,
            &mut self.font_system,
            &mut self.atlas,
            &self.viewport,
            text_areas,
            &mut self.swash_cache,
        )?;
        
        Ok(())
    }

    pub fn render(
        &mut self,
        device: &wgpu::Device,
        target: &wgpu::TextureView,
    ) -> color_eyre::Result<CommandBuffer> {
        let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor { label: None });
        {
            let mut pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                label: None,
                color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                    view: target,
                    resolve_target: None,
                    ops: wgpu::Operations {
                        load: wgpu::LoadOp::Load,
                        store: wgpu::StoreOp::Store,
                    },
                })],
                depth_stencil_attachment: None,
                timestamp_writes: None,
                occlusion_query_set: None,
            });
            self.text_renderer.render(&self.atlas, &self.viewport, &mut pass)?;
        }

        Ok(encoder.finish())
    }

    pub fn cleanup(&mut self) {
        self.atlas.trim();
    }

    fn map_alignment(text_alignment: TextAlignment) -> Align {
        match text_alignment {
            TextAlignment::Start => Align::Left,
            TextAlignment::Center => Align::Center,
            TextAlignment::End => Align::Right,
        }
    }

    fn map_attrs(text_layer: &TextLayer) -> Attrs {
        Attrs::new()
            .weight(Weight(text_layer.font_weight))
            .style(if text_layer.italic { glyphon::Style::Italic } else { glyphon::Style::Normal })
            .family(Family::Name(&text_layer.font))
    }
}
