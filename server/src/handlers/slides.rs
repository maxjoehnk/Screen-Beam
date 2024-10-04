use digital_signage_api::*;

use crate::db::{Database, queries};

pub async fn list_slides(db: &Database) -> color_eyre::Result<Vec<Slide>> {
    let slides = queries::fetch_all_slides(db).await?;

    tracing::debug!("Slides: {:?}", slides);

    let slides: Vec<Slide> = slides.into_iter().map(Slide::from).collect();

    Ok(slides)
}

pub async fn add_slide(db: &Database, req: AddSlideRequest) -> color_eyre::Result<()> {
    queries::insert_slide(db, req.name, req.id.map(uuid::Uuid::from)).await?;

    Ok(())
}

pub async fn update_slide(db: &Database, slide_id: SlideId, req: Slide) -> color_eyre::Result<()> {
    queries::rename_slide(db, slide_id.into(), req.name).await?;
    for layer in &req.layers {
        match layer {
            SlideLayer::Text(text) => {
                if queries::has_text_layer(db, text.id.into()).await? {
                    queries::update_text_layer(db, text.id.into(), text).await?;
                } else {
                    queries::insert_text_layer(db, slide_id.into(), text.id.into(), text).await?;
                }
            }
            SlideLayer::Image(image) => {
                queries::update_image_layer_label(db, image.id.into(), image.label.clone()).await?;
            }
        }
    }
    let layer_ids = req.layers
        .into_iter()
        .map(|layer| match layer {
            SlideLayer::Text(text) => text.id.into(),
            SlideLayer::Image(image) => image.id.into(),
        })
        .collect::<Vec<uuid::Uuid>>();
    queries::delete_old_layers(db, slide_id.into(), layer_ids).await?;

    Ok(())
}

pub async fn delete_slide(db: &Database, slide_id: SlideId) -> color_eyre::Result<()> {
    queries::delete_slide(db, slide_id.into()).await?;

    Ok(())
}
