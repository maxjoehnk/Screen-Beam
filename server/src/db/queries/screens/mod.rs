use itertools::Itertools;
use sqlx::FromRow;

use crate::db::Database;
use crate::db::entities::{ScreenEntity, SlideEntity};

pub async fn fetch_all_screens(db: &Database) -> color_eyre::Result<Vec<(ScreenEntity, Vec<SlideEntity>, u32)>> {
    let screens: Vec<ScreenRowWithSlide> = sqlx::query_as(include_str!("fetch_all_screens.sql"))
        .fetch_all(db.connection.as_ref())
        .await?;

    let screens = screens
        .into_iter()
        .chunk_by(|row| row.screen_id)
        .into_iter()
        .map(|(screen_id, rows)| {
            let rows = rows.collect::<Vec<_>>();
            let screen = ScreenEntity {
                id: screen_id,
                name: rows[0].clone().screen_name,
            };
            let monitor_count = rows[0].assigned_monitor_count;
            let slides = rows.into_iter()
                .filter(|row| row.slide_id.is_some())
                .sorted_by_key(|row| row.ordering)
                .map(|row| SlideEntity {
                    id: row.slide_id.unwrap(),
                    name: row.slide_name.unwrap(),
                    image_layers: vec![],
                    text_layers: vec![],
                    screen_count: 0,
                }).collect();

            (screen, slides, monitor_count)
        })
        .collect();

    Ok(screens)
}

#[derive(Clone, FromRow)]
struct ScreenRowWithSlide {
    screen_id: uuid::Uuid,
    screen_name: String,
    slide_id: Option<uuid::Uuid>,
    slide_name: Option<String>,
    ordering: u32,
    assigned_monitor_count: u32,
}

pub async fn insert_screen(db: &Database, name: String) -> color_eyre::Result<()> {
    let entity = ScreenEntity::new(name);
    sqlx::query(include_str!("insert_screen.sql"))
        .bind(&entity.id)
        .bind(&entity.name)
        .execute(db.connection.as_ref())
        .await?;

    Ok(())
}

pub async fn insert_slide_in_screen(db: &Database, screen_id: uuid::Uuid, slide_id: uuid::Uuid) -> color_eyre::Result<()> {
    sqlx::query(include_str!("insert_slide_into_screen.sql"))
        .bind(screen_id)
        .bind(slide_id)
        .execute(db.connection.as_ref())
        .await?;

    Ok(())
}

pub async fn delete_screen(db: &Database, screen_id: uuid::Uuid) -> color_eyre::Result<()> {
    sqlx::query(include_str!("delete_screen.sql"))
        .bind(screen_id)
        .execute(db.connection.as_ref())
        .await?;

    Ok(())
}

pub async fn remove_slide_from_screen(db: &Database, screen_id: uuid::Uuid, slide_id: uuid::Uuid) -> color_eyre::Result<()> {
    sqlx::query(include_str!("remove_slide.sql"))
        .bind(screen_id)
        .bind(slide_id)
        .execute(db.connection.as_ref())
        .await?;

    Ok(())
}

pub async fn get_screen_slides_with_order(db: &Database, screen_id: uuid::Uuid) -> color_eyre::Result<Vec<(uuid::Uuid, u32)>> {
    let slides: Vec<(uuid::Uuid, u32)> = sqlx::query_as(include_str!("get_screen_slides_with_order.sql"))
        .bind(screen_id)
        .fetch_all(db.connection.as_ref())
        .await?;

    Ok(slides)
}

pub async fn reorder_slides(db: &Database, screen_id: uuid::Uuid, slides: Vec<(uuid::Uuid, u32)>) -> color_eyre::Result<()> {
    let mut tx = db.connection.begin().await?;
    for (slide_id, ordering) in slides {
        sqlx::query(include_str!("update_slide_ordering.sql"))
            .bind(screen_id)
            .bind(slide_id)
            .bind(ordering)
            .execute(&mut *tx)
            .await?;
    }

    tx.commit().await?;

    Ok(())
}
