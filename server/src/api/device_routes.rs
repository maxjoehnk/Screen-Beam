use axum::{Extension, Json, Router};
use axum::extract::Path;
use axum::http::StatusCode;
use axum::response::IntoResponse;
use axum::routing::{get, post, put};
use uuid::Uuid;

use digital_signage_api::*;

use crate::db::Database;
use crate::handlers;

pub fn device_router() -> Router {
    Router::new()
        .route("/", get(list_devices).post(register_device))
        .route("/:device_id", put(update_device).delete(delete_device))
        .route("/:device_id/name", post(rename_device))
        .route("/:device_id/monitors/screens", get(get_monitor_screens))
        .route("/:device_id/monitors/:monitor_id/screen", post(set_screen_on_monitor))
}

async fn list_devices(db: Extension<Database>) -> Json<Vec<Device>> {
    let devices = handlers::devices::list_devices(&db).await.unwrap();

    Json(devices)
}

async fn set_screen_on_monitor(db: Extension<Database>, Path((device_id, monitor)): Path<(Uuid, String)>, Json(req): Json<SetScreenOnMonitorRequest>) -> impl IntoResponse {
    handlers::devices::set_screen_on_monitor(&db, device_id.into(), monitor, req.screen_id).await.unwrap();

    StatusCode::NO_CONTENT
}

async fn get_monitor_screens(db: Extension<Database>, Path(device_id): Path<Uuid>) -> impl IntoResponse {
    let monitors = handlers::devices::get_monitor_screens(&db, device_id.into()).await.unwrap();

    if let Some(monitors) = monitors {
        Json(monitors).into_response()
    }else {
        StatusCode::NOT_FOUND.into_response()
    }
}

async fn register_device(db: Extension<Database>, Json(req): Json<RegisterDeviceRequest>) -> impl IntoResponse {
    let device = handlers::devices::register_device(&db, req).await.unwrap();

    Json(device)
}

async fn update_device(db: Extension<Database>, Path(device_id): Path<Uuid>, Json(req): Json<RegisterDeviceRequest>) -> impl IntoResponse {
    handlers::devices::update_device(&db, device_id.into(), req).await.unwrap();

    StatusCode::NO_CONTENT
}

async fn delete_device(db: Extension<Database>, Path(device_id): Path<Uuid>) -> impl IntoResponse {
    handlers::devices::delete_device(&db, device_id.into()).await.unwrap();

    StatusCode::NO_CONTENT
}

async fn rename_device(db: Extension<Database>, Path(device_id): Path<Uuid>, Json(req): Json<RenameDeviceRequest>) -> impl IntoResponse {
    handlers::devices::rename_device(&db, device_id.into(), req.name).await.unwrap();

    StatusCode::NO_CONTENT
}
