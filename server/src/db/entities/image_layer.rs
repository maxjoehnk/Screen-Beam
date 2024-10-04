use sqlx::FromRow;

#[derive(Debug, Clone, PartialEq, Eq, FromRow)]
pub struct ImageLayerEntity {
    pub layer_id: uuid::Uuid,
    pub slide_id: uuid::Uuid,
    pub layer_label: Option<String>,
    pub content_type: String,
}

#[derive(Debug, Clone, PartialEq, Eq, FromRow)]
pub struct ImageLayerData {
    pub layer_id: uuid::Uuid,
    pub image_data: Vec<u8>,
    pub content_type: String,
    pub layer_label: Option<String>,
}
