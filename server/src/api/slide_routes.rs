use axum::{Extension, Json, Router};
use axum::extract::{Path, Request};
use axum::http::{header, StatusCode};
use axum::response::IntoResponse;
use axum::routing::{get, post, put};
use uuid::Uuid;

use digital_signage_api::{AddSlideRequest, Slide};

use crate::db::Database;
use crate::handlers;

pub fn slide_router() -> Router {
    Router::new()
        .route("/", get(list_slides).post(add_slide))
        .route("/:slide_id", put(update_slide).delete(delete_slide))
        .route("/:slide_id/layers/:layer_id", post(upload_image))
}


async fn list_slides(db: Extension<Database>) -> Json<Vec<Slide>> {
    let slides = handlers::slides::list_slides(&db).await.unwrap();

    Json(slides)
}

async fn add_slide(db: Extension<Database>, Json(req): Json<AddSlideRequest>) -> impl IntoResponse {
    handlers::slides::add_slide(&db, req).await.unwrap();

    StatusCode::NO_CONTENT
}

async fn update_slide(db: Extension<Database>, Path(slide_id): Path<Uuid>, Json(slide): Json<Slide>) -> impl IntoResponse {
    handlers::slides::update_slide(&db, slide_id.into(), slide).await.unwrap();

    StatusCode::NO_CONTENT
}

async fn delete_slide(db: Extension<Database>, Path(slide_id): Path<Uuid>) -> impl IntoResponse {
    handlers::slides::delete_slide(&db, slide_id.into()).await.unwrap();

    StatusCode::NO_CONTENT
}

async fn upload_image(db: Extension<Database>, Path((slide_id, layer_id)): Path<(Uuid, Uuid)>, request: Request) -> impl IntoResponse {
    tracing::debug!("Uploading image to slide {slide_id} layer {layer_id}");
    let content_type = request.headers().get(header::CONTENT_TYPE).unwrap().to_str().unwrap().to_string();
    let stream = request.into_body().into_data_stream();
    if let Err(err) = handlers::layers::upload_image(&db, slide_id.into(), layer_id.into(), stream, content_type).await {
        tracing::error!(err = %err, "Failed to upload image");
        return StatusCode::INTERNAL_SERVER_ERROR;
    }

    StatusCode::NO_CONTENT
}
