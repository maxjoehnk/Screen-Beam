use std::collections::HashMap;

use digital_signage_api::*;

use crate::db::{Database, entities::*, queries};

pub async fn list_devices(db: &Database) -> color_eyre::Result<Vec<Device>> {
    let devices = queries::fetch_all_devices(db).await?;

    let devices = devices
        .into_iter()
        .map(|device| {
            let monitors = device.monitors.into_iter().map(|monitor| {
                DeviceMonitor {
                    identifier: monitor.identifier,
                    width: monitor.width,
                    height: monitor.height,
                    screen: monitor.screen.map(|screen| Screen {
                        id: screen.id.into(),
                        name: screen.name,
                        slides: Default::default(),
                        monitor_usage: 0,
                    }),
                }
            }).collect();

            Device {
                id: device.id.into(),
                name: device.name,
                hostname: device.hostname,
                address: device.ip,
                version: device.version.to_string(),
                monitors,
            }
        })
        .collect();

    Ok(devices)
}

pub async fn set_screen_on_monitor(db: &Database, device_id: DeviceId, monitor_identifier: String, screen_id: ScreenId) -> color_eyre::Result<()> {
    queries::set_screen_on_monitor(db, device_id.into(), monitor_identifier, screen_id.into()).await?;

    Ok(())
}

pub async fn get_monitor_screens(db: &Database, device_id: DeviceId) -> color_eyre::Result<Option<Vec<DeviceMonitor>>> {
    let devices = queries::fetch_all_devices(db).await?;
    let screens = queries::fetch_all_screens(db).await?
        .into_iter()
        .map(|(screen, slides, count)| (screen.id, (screen, slides, count)))
        .collect::<HashMap<_, _>>();
    let slides = queries::fetch_all_slides(db).await?
        .into_iter()
        .map(|slide| (slide.id, slide))
        .collect::<HashMap<_, _>>();

    let device = devices.into_iter()
        .find(|d| device_id == d.id);

    if device.is_none() {
        return Ok(None);
    }
    let device = device.unwrap();
    let monitors = device.monitors
        .into_iter()
        .map(|monitor| {
            let screen = monitor.screen_id
                .and_then(|screen_id| screens.get(&screen_id))
                .map(|(screen, screen_slides, monitor_usage)| Screen {
                    id: screen.id.into(),
                    name: screen.name.clone(),
                    slides: screen_slides.iter()
                        .filter_map(|slide| slides.get(&slide.id).cloned().map(Slide::from))
                        .collect(),
                    monitor_usage: *monitor_usage as usize,
                });

            DeviceMonitor {
                identifier: monitor.identifier,
                width: monitor.width,
                height: monitor.height,
                screen
            }
        })
        .collect();


    Ok(Some(monitors))
}

pub async fn register_device(db: &Database, request: RegisterDeviceRequest) -> color_eyre::Result<Device> {
    let device_id = DeviceId::new();
    let mut entity = DeviceEntity::from(&request);
    entity.id = device_id.into();
    
    queries::register_device(db, entity).await?;

    let device = Device {
        id: device_id,
        name: None,
        hostname: request.hostname,
        address: request.address,
        version: request.version,
        monitors: request.monitors.iter().map(|monitor| {
            DeviceMonitor {
                identifier: monitor.identifier.clone(),
                width: monitor.width,
                height: monitor.height,
                screen: None,
            }
        }).collect(),
    };

    Ok(device)
}

pub async fn update_device(db: &Database, device_id: DeviceId, request: RegisterDeviceRequest) -> color_eyre::Result<()> {
    let mut entity = DeviceEntity::from(&request);
    entity.id = device_id.into();
    
    queries::update_device(db, entity).await?;

    Ok(())
}

pub async fn delete_device(db: &Database, device_id: DeviceId) -> color_eyre::Result<()> {
    queries::delete_device(db, device_id.into()).await?;

    Ok(())
}

pub async fn rename_device(db: &Database, device_id: DeviceId, name: String) -> color_eyre::Result<()> {
    queries::rename_device(db, device_id.into(), &name).await?;

    Ok(())
}

impl From<&RegisterDeviceRequest> for DeviceEntity {
    fn from(request: &RegisterDeviceRequest) -> Self {
        let version = request.version.split('.').collect::<Vec<_>>();
        let version = DeviceVersion {
            major: version[0].parse().unwrap(),
            minor: version[1].parse().unwrap(),
            patch: version[2].parse().unwrap(),
        };
        let device_id = DeviceId::default();
        let entity = DeviceEntity {
            id: device_id.into(),
            name: None,
            ip: request.address,
            hostname: request.hostname.clone(),
            version,
            monitors: request.monitors.iter().map(|monitor| {
                DeviceMonitorEntity {
                    device_id: device_id.into(),
                    identifier: monitor.identifier.clone(),
                    width: monitor.width,
                    height: monitor.height,
                    screen_id: None,
                    screen: None,
                }
            }).collect(),
        };
        
        entity
    }
}
