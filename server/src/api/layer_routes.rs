use axum::{Extension, Router};
use axum::extract::Path;
use axum::http::{header, StatusCode};
use axum::response::IntoResponse;
use axum::routing::get;
use uuid::Uuid;

use crate::db::Database;
use crate::handlers;

pub fn layer_router() -> Router {
    Router::new()
        .route("/:layer_id/data", get(get_image_data))
}

async fn get_image_data(db: Extension<Database>, Path(layer_id): Path<Uuid>) -> impl IntoResponse {
    match handlers::layers::read_image(&db, layer_id.into()).await {
        Ok(Some(image)) => {
            (StatusCode::OK, [(header::CONTENT_TYPE, image.content_type)], image.image_data).into_response()
        }
        Ok(None) => StatusCode::NOT_FOUND.into_response(),
        Err(err) => {
            tracing::error!(err = %err, "Failed to read image data");
            StatusCode::INTERNAL_SERVER_ERROR.into_response()
        }
    }
}
