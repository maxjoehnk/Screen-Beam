use sqlx::{FromRow};
use uuid::Uuid;

use digital_signage_api::TextLayer;

use crate::db::Database;
use crate::db::entities::ImageLayerData;

pub async fn fetch_image_layer_data(db: &Database, layer_id: Uuid) -> color_eyre::Result<Option<ImageLayerData>> {
    let data = sqlx::query_as(
        include_str!("read_image_data.sql")
    )
        .bind(&layer_id)
        .fetch_optional(db.connection.as_ref())
        .await?;

    Ok(data)
}

pub async fn insert_image_layer_data(db: &Database, slide_id: Uuid, layer_id: Uuid, data: Vec<u8>, content_type: String, label: Option<String>) -> color_eyre::Result<()> {
    let row: LayerCount = sqlx::query_as(include_str!("count_image_layers.sql"))
        .bind(&layer_id)
        .fetch_one(db.connection.as_ref())
        .await?;

    if row.count > 0 {
        sqlx::query(
            include_str!("update_image_data.sql")
        )
            .bind(&layer_id)
            .bind(&data)
            .bind(&content_type)
            .bind(&label)
            .execute(db.connection.as_ref())
            .await?;
    } else {
        sqlx::query(
            include_str!("insert_image_layer.sql")
        )
            .bind(&slide_id)
            .bind(&layer_id)
            .bind(&data)
            .bind(&content_type)
            .bind(&label)
            .execute(db.connection.as_ref())
            .await?;
    }

    Ok(())
}

#[derive(Debug, FromRow)]
struct LayerCount {
    count: u32,
}

pub async fn insert_text_layer(db: &Database, slide_id: Uuid, layer_id: Uuid, layer: &TextLayer) -> color_eyre::Result<()> {
    let shadow = layer.shadow.as_ref();
    sqlx::query(
        include_str!("insert_text_layer.sql")
    )
        .bind(&layer_id)
        .bind(&slide_id)
        .bind(&layer.text)
        .bind(&layer.font)
        .bind(&layer.font_size)
        .bind(&layer.line_height)
        .bind(&layer.x)
        .bind(&layer.y)
        .bind(&layer.color.red)
        .bind(&layer.color.green)
        .bind(&layer.color.blue)
        .bind(&layer.color.alpha)
        .bind(shadow.map(|shadow| shadow.x_offset))
        .bind(shadow.map(|shadow| shadow.y_offset))
        .bind(shadow.map(|shadow| shadow.color.red))
        .bind(shadow.map(|shadow| shadow.color.green))
        .bind(shadow.map(|shadow| shadow.color.blue))
        .bind(shadow.map(|shadow| shadow.color.alpha))
        .bind(&(layer.alignment as u8))
        .bind(&(layer.font_weight as u32))
        .bind(&(layer.italic as u8))
        .bind(&layer.label)
        .execute(db.connection.as_ref())
        .await?;

    Ok(())
}

pub async fn update_text_layer(db: &Database, layer_id: Uuid, layer: &TextLayer) -> color_eyre::Result<()> {
    let shadow = layer.shadow.as_ref();
    sqlx::query(
        include_str!("update_text_layer.sql")
    )
        .bind(&layer_id)
        .bind(&layer.text)
        .bind(&layer.font)
        .bind(&layer.font_size)
        .bind(&layer.line_height)
        .bind(&layer.x)
        .bind(&layer.y)
        .bind(&layer.color.red)
        .bind(&layer.color.green)
        .bind(&layer.color.blue)
        .bind(&layer.color.alpha)
        .bind(shadow.map(|shadow| shadow.x_offset))
        .bind(shadow.map(|shadow| shadow.y_offset))
        .bind(shadow.map(|shadow| shadow.color.red))
        .bind(shadow.map(|shadow| shadow.color.green))
        .bind(shadow.map(|shadow| shadow.color.blue))
        .bind(shadow.map(|shadow| shadow.color.alpha))
        .bind(&(layer.alignment as u8))
        .bind(&(layer.font_weight as u32))
        .bind(&(layer.italic as u8))
        .bind(&layer.label)
        .execute(db.connection.as_ref())
        .await?;

    Ok(())
}

pub async fn has_text_layer(db: &Database, layer_id: Uuid) -> color_eyre::Result<bool> {
    let row: LayerCount = sqlx::query_as(include_str!("count_text_layers.sql"))
        .bind(&layer_id)
        .fetch_one(db.connection.as_ref())
        .await?;

    Ok(row.count > 0)
}

pub async fn update_image_layer_label(db: &Database, layer_id: Uuid, label: Option<String>) -> color_eyre::Result<()> {
    sqlx::query(
        include_str!("update_image_layer_label.sql")
    )
        .bind(&layer_id)
        .bind(&label)
        .execute(db.connection.as_ref())
        .await?;

    Ok(())
}