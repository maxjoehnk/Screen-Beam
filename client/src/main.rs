use std::sync::{Arc, mpsc};
use std::sync::atomic::AtomicBool;
use tracing_subscriber::layer::SubscriberExt;
use tracing_subscriber::util::SubscriberInitExt;

use crate::config_loader::ConfigLoader;
use crate::config_store::ConfigStore;
use crate::image_cache::ImageCache;
use crate::tokio_thread::spawn_tokio_thread;

mod renderer;
mod config_loader;
mod config_store;
mod tokio_thread;
mod image_cache;
mod mdns_discovery;

fn main() -> color_eyre::Result<()> {
    color_eyre::install()?;
    tracing_subscriber::registry()
        .with(tracing_subscriber::fmt::layer())
        .with(tracing_subscriber::EnvFilter::from_default_env())
        .init();

    let image_notifier = Arc::new(AtomicBool::new(false));
    let images_cached = mpsc::channel();
    let config_store = ConfigStore::new();
    let image_cache = ImageCache::new(Arc::clone(&image_notifier), images_cached.0);

    let renderer = futures::executor::block_on(renderer::Renderer::new(image_cache, images_cached.1))?;

    let monitors = renderer.get_monitors();
    let host_receiver = mdns_discovery::discover()?;
    let thread_config_store = config_store.clone();

    spawn_tokio_thread(move || async move {
        let config_store = thread_config_store;
        config_store.try_load().await?;

        let host = host_receiver.recv_async().await?;

        tracing::info!("Found server: {host}");

        let config_loader = ConfigLoader::new(&host).await?;

        let config = if let Some(mut config) = config_store.get() {
            config_loader.update(&config, monitors).await?;
            if let Err(err) = config_loader.refresh_screens(&mut config).await {
                tracing::error!(error = ?err, "Error refreshing screens");
            }
            config
        }else {
            config_loader.register(monitors).await?
        };
        if let Err(err) = config_loader.cache_images(&config).await {
            tracing::error!(error = ?err, "Error caching images");
        }
        if let Err(err) = config_store.update(config).await {
            tracing::error!(error = ?err, "Error storing device config");
        }
        image_notifier.store(false, std::sync::atomic::Ordering::Relaxed);

        loop {
            tokio::time::sleep(std::time::Duration::from_secs(5)).await;
            if let Some(mut device) = config_store.get() {
                tracing::info!("Refreshing device config");
                if let Err(err) = config_loader.refresh_screens(&mut device).await {
                    tracing::error!(error = ?err, "Error refreshing screens");
                }else {
                    if let Err(err) = config_loader.cache_images(&device).await {
                        tracing::error!(error = ?err, "Error caching images");
                    }
                    config_store.update(device).await?;
                    image_notifier.store(false, std::sync::atomic::Ordering::Relaxed);
                }
            }
        }
    });

    renderer.run(config_store)?;

    Ok(())
}
