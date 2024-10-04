use std::collections::HashMap;

use digital_signage_api::*;

use crate::db::{Database, queries};

pub async fn list_screens(db: &Database) -> color_eyre::Result<Vec<Screen>> {
    let screens = queries::fetch_all_screens(db).await?;
    let slides = queries::fetch_all_slides(db).await?;
    let slides = slides.into_iter().map(|slide| (slide.id, slide)).collect::<HashMap<_, _>>();

    tracing::debug!("Screens: {:?}", screens);

    let screens = screens
        .into_iter()
        .map(|(screen, screen_slides, monitor_usage)| {
            let screen_slides = screen_slides.into_iter().flat_map(|slide| slides.get(&slide.id).cloned()).map(Slide::from).collect();

            Screen {
                id: screen.id.into(),
                name: screen.name,
                slides: screen_slides,
                monitor_usage: monitor_usage as usize,
            }
        })
        .collect();

    Ok(screens)
}

pub async fn add_screen(db: &Database, req: AddScreenRequest) -> color_eyre::Result<()> {
    queries::insert_screen(db, req.name).await?;

    Ok(())
}

pub async fn add_slide_to_screen(db: &Database, screen_id: ScreenId, slide_id: SlideId) -> color_eyre::Result<()> {
    queries::insert_slide_in_screen(db, screen_id.into(), slide_id.into()).await?;

    Ok(())
}

pub async fn delete_screen(db: &Database, screen_id: ScreenId) -> color_eyre::Result<()> {
    queries::delete_screen(db, screen_id.into()).await?;

    Ok(())
}

pub async fn remove_slide_from_screen(db: &Database, screen_id: ScreenId, slide_id: SlideId) -> color_eyre::Result<()> {
    queries::remove_slide_from_screen(db, screen_id.into(), slide_id.into()).await?;

    Ok(())
}

pub async fn reorder_slides(db: &Database, screen_id: ScreenId, old_index: usize, new_index: usize) -> color_eyre::Result<()> {
    let slides = queries::get_screen_slides_with_order(db, screen_id.into()).await?;
    if old_index > slides.len() || new_index > slides.len() {
        return Err(color_eyre::eyre::eyre!("Invalid index, slides: {}, old_index: {old_index}, new_index: {new_index}", slides.len()));
    }
    
    let slide_id = slides[old_index].0;
    
    let slides = slides.into_iter().map(|(id, order)| {
        if id == slide_id {
            (id, new_index as u32)
        } else if old_index < new_index && order > old_index as u32 && order <= new_index as u32 {
            (id, order - 1)
        } else if old_index > new_index && order >= new_index as u32 && order < old_index as u32 {
            (id, order + 1)
        } else {
            (id, order)
        }
    }).collect::<Vec<_>>();
    
    queries::reorder_slides(db, screen_id.into(), slides).await?;

    Ok(())
}
