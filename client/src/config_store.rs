use std::sync::Arc;
use std::sync::atomic::AtomicBool;
use pinboard::Pinboard;
use tokio::fs;
use digital_signage_api::Device;

#[derive(Clone)]
pub struct ConfigStore {
    config: Arc<Pinboard<Device>>,
    has_changed: Arc<AtomicBool>,
}

impl ConfigStore {
    pub fn new() -> Self {
        Self {
            config: Arc::new(Pinboard::new_empty()),
            has_changed: Arc::new(AtomicBool::new(false)),
        }
    }
    
    pub async fn try_load(&self) -> color_eyre::Result<()> {
        if fs::try_exists(".device.json").await? {
            self.load().await?;
        }
        
        Ok(())
    }
    
    async fn load(&self) -> color_eyre::Result<()> {
        let device = fs::read_to_string(".device.json").await?;
        let device = serde_json::from_str(&device)?;
        
        self.publish(device);
        
        Ok(())
    }
    
    pub async fn update(&self, config: Device) -> color_eyre::Result<()> {
        fs::write(".device.json", serde_json::to_string(&config)?).await?;
        self.publish(config);
        
        Ok(())
    }

    fn publish(&self, config: Device) {
        self.config.set(config);
        self.has_changed.store(true, std::sync::atomic::Ordering::Relaxed);
    }

    pub fn get(&self) -> Option<Device> {
        self.config.read()
    }

    pub fn get_changed(&self) -> (Option<Device>, bool) {
        (self.config.read(), self.has_changed.swap(false, std::sync::atomic::Ordering::Relaxed))
    }
}
