use axum::{Extension, Json, Router};
use axum::extract::Path;
use axum::http::StatusCode;
use axum::response::IntoResponse;
use axum::routing::{delete, get, post};
use uuid::Uuid;

use digital_signage_api::{AddScreenRequest, AddSlideToScreenRequest, ReorderSlidesRequest, Screen};

use crate::db::Database;
use crate::handlers;

pub fn screen_router() -> Router {
    Router::new()
        .route("/", get(list_screens).post(add_screen))
        .route("/:screen_id", delete(delete_screen))
        .route("/:screen_id/slides", post(add_slide_to_screen))
        .route("/:screen_id/slides/:slide_id", delete(remove_slide_from_screen))
        .route("/:screen_id/slides/reorder", post(reorder_slides))
}

async fn list_screens(db: Extension<Database>) -> Json<Vec<Screen>> {
    let screens = handlers::screens::list_screens(&db).await.unwrap();

    Json(screens)
}

async fn add_screen(db: Extension<Database>, Json(req): Json<AddScreenRequest>) -> impl IntoResponse {
    handlers::screens::add_screen(&db, req).await.unwrap();

    StatusCode::NO_CONTENT
}

async fn add_slide_to_screen(db: Extension<Database>, Path(screen_id): Path<Uuid>, Json(req): Json<AddSlideToScreenRequest>) -> impl IntoResponse {
    handlers::screens::add_slide_to_screen(&db, screen_id.into(), req.slide_id).await.unwrap();

    StatusCode::NO_CONTENT
}

async fn delete_screen(db: Extension<Database>, Path(screen_id): Path<Uuid>) -> impl IntoResponse {
    handlers::screens::delete_screen(&db, screen_id.into()).await.unwrap();

    StatusCode::NO_CONTENT
}

async fn remove_slide_from_screen(db: Extension<Database>, Path((screen_id, slide_id)): Path<(Uuid, Uuid)>) -> impl IntoResponse {
    handlers::screens::remove_slide_from_screen(&db, screen_id.into(), slide_id.into()).await.unwrap();

    StatusCode::NO_CONTENT
}

async fn reorder_slides(db: Extension<Database>, Path(screen_id): Path<Uuid>, Json(req): Json<ReorderSlidesRequest>) -> impl IntoResponse {
    handlers::screens::reorder_slides(&db, screen_id.into(), req.old_index, req.new_index).await.unwrap();

    StatusCode::NO_CONTENT
}
