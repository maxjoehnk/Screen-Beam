use tracing_subscriber::layer::SubscriberExt;
use tracing_subscriber::util::SubscriberInitExt;

mod db;
mod api;
mod mappers;
mod handlers;
mod mdns;

#[tokio::main]
async fn main() -> color_eyre::Result<()> {
    color_eyre::install()?;
    tracing_subscriber::registry()
        .with(tracing_subscriber::fmt::layer())
        .with(tracing_subscriber::EnvFilter::from_default_env())
        .init();

    let database = db::Database::connect().await?;
    
    if let Err(err) = mdns::announce(3000) {
        tracing::error!("Failed to announce server via mdns: {err:?}");
    }
    
    api::serve(database).await?;

    Ok(())
}
