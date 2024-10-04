use sqlx::FromRow;
use uuid::Uuid;
use crate::db::Database;
use crate::db::entities::{ImageLayerEntity, SlideEntity, TextLayerEntity};

pub async fn fetch_all_slides(db: &Database) -> color_eyre::Result<Vec<SlideEntity>> {
    let mut slides: Vec<SlideEntity> = sqlx::query_as(
        include_str!("fetch_all_slides.sql")
    )
        .fetch_all(db.connection.as_ref())
        .await?;
    let image_layers: Vec<ImageLayerEntity> = sqlx::query_as(
        include_str!("fetch_all_image_layers.sql")
    )
        .fetch_all(db.connection.as_ref())
        .await?;
    let text_layers: Vec<TextLayerEntity> = sqlx::query_as(
        include_str!("fetch_all_text_layers.sql")
    )
        .fetch_all(db.connection.as_ref())
        .await?;

    for slide in slides.iter_mut() {
        slide.image_layers = image_layers
            .iter()
            .filter(|image_layer| image_layer.slide_id == slide.id)
            .cloned()
            .collect();
        slide.text_layers = text_layers
            .iter()
            .filter(|text_layer| text_layer.slide_id == slide.id)
            .cloned()
            .collect();
    }

    Ok(slides)
}

pub async fn insert_slide(db: &Database, name: String, id: Option<Uuid>) -> color_eyre::Result<()> {
    let mut entity = SlideEntity::new(name);
    if let Some(id) = id {
        entity.id = id;
    }
    sqlx::query(include_str!("insert_slide.sql"))
        .bind(&entity.id)
        .bind(&entity.name)
        .execute(db.connection.as_ref())
        .await?;

    Ok(())
}

pub async fn rename_slide(db: &Database, slide_id: uuid::Uuid, name: String) -> color_eyre::Result<()> {
    sqlx::query(include_str!("rename_slide.sql"))
        .bind(&slide_id)
        .bind(&name)
        .execute(db.connection.as_ref())
        .await?;

    Ok(())
}

pub async fn delete_slide(db: &Database, slide_id: uuid::Uuid) -> color_eyre::Result<()> {
    sqlx::query(include_str!("delete_slide.sql"))
        .bind(slide_id)
        .execute(db.connection.as_ref())
        .await?;

    Ok(())
}

pub async fn delete_old_layers(db: &Database, slide_id: uuid::Uuid, layer_ids: Vec<uuid::Uuid>) -> color_eyre::Result<()> {
    tracing::debug!("Removing layers except {:?}", layer_ids);
    let text_layers: Vec<Layer> = sqlx::query_as(
        include_str!("fetch_slide_text_layers.sql")
    )
        .bind(&slide_id)
        .fetch_all(db.connection.as_ref())
        .await?;
    let image_layers: Vec<Layer> = sqlx::query_as(
        include_str!("fetch_slide_image_layers.sql")
    )
        .bind(&slide_id)
        .fetch_all(db.connection.as_ref())
        .await?;

    let existing_layer_ids = text_layers
        .into_iter()
        .chain(image_layers.into_iter())
        .map(|layer| layer.layer_id)
        .collect::<Vec<_>>();
    
    tracing::debug!("Existing layers: {:?}", existing_layer_ids);

    let obsolete_layer_ids = existing_layer_ids
        .into_iter()
        .filter(|layer_id| !layer_ids.contains(layer_id))
        .collect::<Vec<_>>();
    
    tracing::debug!("Removing layers: {:?}", obsolete_layer_ids);

    for layer_id in obsolete_layer_ids {
        sqlx::query(include_str!("delete_old_layers.sql"))
            .bind(&slide_id)
            .bind(&layer_id)
            .execute(db.connection.as_ref())
            .await?;
    }

    Ok(())
}

#[derive(FromRow)]
struct Layer {
    layer_id: uuid::Uuid,
}
