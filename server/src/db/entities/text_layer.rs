use sqlx::FromRow;

#[derive(Debug, Clone, PartialEq, Eq, FromRow)]
pub struct TextLayerEntity {
    pub layer_id: uuid::Uuid,
    pub slide_id: uuid::Uuid,
    pub layer_label: Option<String>,
    pub x: i32,
    pub y: i32,
    pub text: String,
    pub font: String,
    pub font_size: u32,
    pub line_height: Option<u32>,
    pub color_red: u8,
    pub color_green: u8,
    pub color_blue: u8,
    pub color_alpha: u8,
    pub text_alignment: u8,
    pub font_weight: u32,
    pub italic: u8,
    #[sqlx(flatten)]
    pub shadow: ShadowEntity,
}

#[derive(Debug, Clone, PartialEq, Eq, FromRow)]
pub struct ShadowEntity {
    pub shadow_offset_x: Option<i32>,
    pub shadow_offset_y: Option<i32>,
    pub shadow_color_red: Option<u8>,
    pub shadow_color_green: Option<u8>,
    pub shadow_color_blue: Option<u8>,
    pub shadow_color_alpha: Option<u8>,
}
