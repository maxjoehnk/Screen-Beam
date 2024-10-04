use axum::{Extension, Router};
use tokio::net::TcpListener;
use tower_http::trace::TraceLayer;

use crate::api::device_routes::device_router;
use crate::api::layer_routes::layer_router;
use crate::api::screen_routes::screen_router;
use crate::api::slide_routes::slide_router;
use crate::db::Database;

mod device_routes;
mod screen_routes;
mod slide_routes;
mod layer_routes;

pub async fn serve(db: Database) -> color_eyre::Result<()> {
    let app = Router::new()
        .nest("/api", create_router())
        .layer(TraceLayer::new_for_http())
        .layer(Extension(db));

    let listener = TcpListener::bind("0.0.0.0:3000").await?;

    tracing::info!("Opening server on http://0.0.0.0:3000");

    axum::serve(listener, app).await?;

    Ok(())
}

fn create_router() -> Router {
    Router::new()
        .nest("/devices", device_router())
        .nest("/screens", screen_router())
        .nest("/slides", slide_router())
        .nest("/layers", layer_router())
}
