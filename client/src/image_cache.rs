use std::collections::HashMap;
use std::ops::Deref;
use std::sync::Arc;
use std::sync::atomic::AtomicBool;
use std::sync::mpsc::Sender;

use color_eyre::eyre::Context;
use image::DynamicImage;
use parking_lot::{RwLock, RwLockReadGuard};

use digital_signage_api::{Device, ImageLayer, LayerId, SlideLayer};

pub struct ImageCache {
    images: Arc<RwLock<HashMap<LayerId, DynamicImage>>>,
    image_cached_notifier: Arc<AtomicBool>,
    is_caching: Arc<AtomicBool>,
    images_cached: Sender<()>,
}

impl ImageCache {
    pub fn new(image_cached_notifier: Arc<AtomicBool>, images_cached: Sender<()>) -> Self {
        Self {
            images: Arc::new(RwLock::new(HashMap::new())),
            image_cached_notifier,
            is_caching: Arc::new(AtomicBool::new(false)),
            images_cached,
        }
    }

    pub fn load_images(&self, config: &Device) {
        if self.image_cached_notifier.load(std::sync::atomic::Ordering::Relaxed) ||
            self.is_caching.load(std::sync::atomic::Ordering::Relaxed) {
            return;
        }
        self.is_caching.store(true, std::sync::atomic::Ordering::Relaxed);
        let device = config.clone();
        let images = self.images.clone();
        let image_cached_notifier = Arc::clone(&self.image_cached_notifier);
        let is_caching = Arc::clone(&self.is_caching);
        let images_cached = self.images_cached.clone();
        std::thread::spawn(move || {
            tracing::debug!("Decoding images...");
            let mut errors = 0;
            for layer in device.monitors
                .into_iter()
                .filter_map(|monitor| monitor.screen)
                .flat_map(|screen| screen.slides)
                .flat_map(|slide| slide.layers)
                .filter_map(|layer| if let SlideLayer::Image(image) = layer { Some(image) } else { None }) {
                match read_image(&layer) {
                    Ok(image) => {
                        images.write().insert(layer.id, image);
                    }
                    Err(err) => {
                        tracing::error!(error = ?err, "Error reading image");
                        errors += 1;
                    }
                }
            }
            tracing::debug!("Decoded images!");
            image_cached_notifier.store(errors == 0, std::sync::atomic::Ordering::Relaxed);
            is_caching.store(false, std::sync::atomic::Ordering::Relaxed);
            images_cached.send(()).unwrap();
        });
    }

    pub fn get_image(&self, id: &LayerId) -> Option<ImageRef> {
        let images = self.images.read();
        if !images.contains_key(id) {
            return None;
        }

        Some(ImageRef(images, *id))
    }
}

pub struct ImageRef<'a>(RwLockReadGuard<'a, HashMap<LayerId, DynamicImage>>, LayerId);

impl<'a> Deref for ImageRef<'a> {
    type Target = DynamicImage;

    fn deref(&self) -> &Self::Target {
        &self.0[&self.1]
    }
}

fn read_image(layer: &ImageLayer) -> color_eyre::Result<DynamicImage> {
    let image_path = format!(".cache/{}.{}", layer.id, layer.extension());
    let image = image::ImageReader::open(&image_path).context(format!("Opening image {image_path}"))?.with_guessed_format()?.decode()?;
    let image = image.to_rgba8().into();

    Ok(image)
}

pub trait ImageLayerCacheExt {
    fn extension(&self) -> &str;
}

impl ImageLayerCacheExt for ImageLayer {
    fn extension(&self) -> &str {
        match self.content_type.as_str() {
            "image/png" => "png",
            "image/jpeg" | "image/jpg" => "jpg",
            _ => ""
        }
    }
}
