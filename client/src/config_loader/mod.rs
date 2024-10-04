use serde::de::DeserializeOwned;
use tokio::fs;
use url::Url;
use digital_signage_api::{Device, DeviceMonitor, DeviceMonitorInfo, RegisterDeviceRequest, SlideLayer};
use crate::config_loader::api_client::ApiClient;

mod api_client;

pub struct ConfigLoader {
    client: ApiClient,
}

impl ConfigLoader {
    pub async fn new(host: &str) -> color_eyre::Result<Self> {
        let host = Url::parse(host)?;

        let client = ApiClient::new(host);
        
        fs::create_dir_all(".cache").await?;

        Ok(Self {
            client,
        })
    }

    pub async fn register(&self, monitors: Vec<DeviceMonitorInfo>) -> color_eyre::Result<Device> {
        tracing::info!("Registering device config...");
        let device = Device::register(&self.client, monitors).await?;

        tracing::debug!("Device config: {device:?}");

        Ok(device)
    }

    pub async fn update(&self, device: &Device, monitors: Vec<DeviceMonitorInfo>) -> color_eyre::Result<()> {
        tracing::info!("Updating device registration...");
        device.update(&self.client, monitors).await?;

        Ok(())
    }

    pub async fn cache_images(&self, device: &Device) -> color_eyre::Result<()> {
        for monitor in device.monitors.iter() {
            if let Some(screen) = &monitor.screen {
                for slide in screen.slides.iter() {
                    for layer in &slide.layers {
                        if let SlideLayer::Image(layer) = layer {
                            let res = self.client.get(&format!("/api/layers/{}/data", &layer.id)).await?;
                            let bytes = res.bytes().await?;
                            let extension = match layer.content_type.as_str() {
                                "image/png" => "png",
                                "image/jpeg" | "image/jpg" => "jpg",
                                _ => ""
                            };
                            fs::write(format!(".cache/{}.{}", &layer.id, extension), bytes).await?;
                        }
                    }
                }
            }
        }

        Ok(())
    }

    pub async fn refresh_screens(&self, device: &mut Device) -> color_eyre::Result<()> {
        device.refresh_screens(&self.client).await?;

        Ok(())
    }
}

trait DeviceRegistration: Sized + DeserializeOwned {
    async fn register(client: &ApiClient, monitors: Vec<DeviceMonitorInfo>) -> color_eyre::Result<Self>;
    async fn update(&self, client: &ApiClient, monitors: Vec<DeviceMonitorInfo>) -> color_eyre::Result<()>;
    
    async fn refresh_screens(&mut self, client:  &ApiClient) -> color_eyre::Result<()>;

    fn get_registration(monitors: Vec<DeviceMonitorInfo>) -> color_eyre::Result<RegisterDeviceRequest> ;
}

impl DeviceRegistration for Device {
    async fn register(client: &ApiClient, monitors: Vec<DeviceMonitorInfo>) -> color_eyre::Result<Self> {
        let res = client.post("/api/devices", &Self::get_registration(monitors)?)
            .await?;

        let device = res.json().await?;

        Ok(device)
    }

    async fn update(&self, client: &ApiClient, monitors: Vec<DeviceMonitorInfo>) -> color_eyre::Result<()> {
        let res = client.put(&format!("/api/devices/{}", self.id), &Self::get_registration(monitors)?)
            .await?;
        
        res.error_for_status()?;

        Ok(())
    }

    async fn refresh_screens(&mut self, client: &ApiClient) -> color_eyre::Result<()> {
        let res = client.get(&format!("/api/devices/{}/monitors/screens", &self.id)).await?;
        let monitors: Vec<DeviceMonitor> = res.json().await?;
        for monitor in self.monitors.iter_mut() {
            monitor.screen = monitors.iter().find(|m| m.identifier == monitor.identifier).and_then(|m| m.screen.clone());
        }

        Ok(())
    }

    fn get_registration(monitors: Vec<DeviceMonitorInfo>) -> color_eyre::Result<RegisterDeviceRequest> {
        let interface = netdev::get_default_interface().map_err(|err| color_eyre::eyre::eyre!("Failed to get default interface: {err:?}"))?;

        Ok(RegisterDeviceRequest {
            version: env!("CARGO_PKG_VERSION").to_string(),
            address: interface.ipv4.first().ok_or(color_eyre::eyre::eyre!("No IPv4 address found"))?.addr().into(),
            hostname: hostname::get()?.into_string().unwrap(),
            monitors,
        })
    }
}
