use digital_signage_api::*;
use crate::db::entities::*;

impl From<SlideEntity> for Slide {
    fn from(value: SlideEntity) -> Self {
        Self {
            id: value.id.into(),
            name: value.name,
            layers: value.image_layers
                .into_iter()
                .map(|image_layer| image_layer.into())
                .chain(
                    value.text_layers
                        .into_iter()
                        .map(|text_layer| text_layer.into())
                )
                .collect(),
            screen_usage: value.screen_count as usize,
        }
    }
}

impl From<ImageLayerEntity> for SlideLayer {
    fn from(value: ImageLayerEntity) -> Self {
        Self::Image(ImageLayer {
            id: value.layer_id.into(),
            content_type: value.content_type,
            label: value.layer_label,
        })
    }
}

impl From<TextLayerEntity> for SlideLayer {
    fn from(value: TextLayerEntity) -> Self {
        Self::Text(TextLayer {
            id: value.layer_id.into(),
            text: value.text,
            x: value.x,
            y: value.y,
            font_size: value.font_size,
            color: Color {
                red: value.color_red,
                green: value.color_green,
                blue: value.color_blue,
                alpha: value.color_alpha,
            },
            line_height: value.line_height,
            font: value.font,
            shadow: value.shadow.into(),
            alignment: value.text_alignment.try_into().unwrap_or_default(),
            font_weight: value.font_weight as u16,
            italic: value.italic > 0,
            label: value.layer_label,
        })
    }
}

impl From<ShadowEntity> for Option<Shadow> {
    fn from(shadow: ShadowEntity) -> Self {
        Some(Shadow {
            y_offset: shadow.shadow_offset_y?,
            x_offset: shadow.shadow_offset_x?,
            color: Color {
                red: shadow.shadow_color_red?,
                green: shadow.shadow_color_green?,
                blue: shadow.shadow_color_blue?,
                alpha: shadow.shadow_color_alpha?,
            },
        })
    }
}
