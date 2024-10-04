use sqlx::FromRow;
use super::{ImageLayerEntity, TextLayerEntity};

#[derive(Debug, Clone, PartialEq, Eq, FromRow)]
pub struct SlideEntity {
    pub id: uuid::Uuid,
    pub name: String,
    #[sqlx(skip)]
    pub text_layers: Vec<TextLayerEntity>,
    #[sqlx(skip)]
    pub image_layers: Vec<ImageLayerEntity>,
    pub screen_count: u32,
}

impl SlideEntity {
    pub fn new(name: String) -> Self {
        Self {
            id: uuid::Uuid::new_v4(),
            name,
            text_layers: vec![],
            image_layers: vec![],
            screen_count: 0,
        }
    }
}
