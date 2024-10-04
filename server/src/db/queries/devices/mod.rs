use std::collections::HashSet;
use std::net::IpAddr;
use std::str::FromStr;

use itertools::Itertools;
use sqlx::FromRow;

use crate::db::Database;
use crate::db::entities::*;

pub async fn fetch_all_devices(db: &Database) -> color_eyre::Result<Vec<DeviceEntity>> {
    let devices: Vec<DeviceRowWithMonitor> = sqlx::query_as(
        include_str!("fetch_all_devices.sql")
    )
        .fetch_all(db.connection.as_ref())
        .await?;

    let devices = devices
        .into_iter()
        .chunk_by(|row| row.device_id)
        .into_iter()
        .map(|(device_id, rows)| {
            let rows = rows.collect::<Vec<_>>();
            let row = rows[0].clone();
            let device = DeviceEntity {
                id: device_id,
                name: row.device_name,
                ip: IpAddr::from_str(&row.device_ip).unwrap(),
                hostname: row.device_hostname,
                version: DeviceVersion {
                    major: row.device_version_major,
                    minor: row.device_version_minor,
                    patch: row.device_version_patch,
                },
                monitors: rows.into_iter()
                    .filter(|row| row.monitor_identifier.is_some())
                    .map(|row| DeviceMonitorEntity {
                        device_id: row.device_id,
                        identifier: row.monitor_identifier.unwrap(),
                        width: row.monitor_width.unwrap(),
                        height: row.monitor_height.unwrap(),
                        screen_id: row.monitor_screen_id,
                        screen: row.screen_id.map(|screen_id| ScreenEntity {
                            id: screen_id,
                            name: row.screen_name.clone().unwrap(),
                        }),
                    }).collect(),
            };

            device
        })
        .collect();


    Ok(devices)
}

#[derive(Clone, FromRow)]
struct DeviceRowWithMonitor {
    device_id: uuid::Uuid,
    device_name: Option<String>,
    device_ip: String,
    device_hostname: String,
    device_version_major: u32,
    device_version_minor: u32,
    device_version_patch: u32,
    monitor_identifier: Option<String>,
    monitor_width: Option<u32>,
    monitor_height: Option<u32>,
    monitor_screen_id: Option<uuid::Uuid>,
    screen_id: Option<uuid::Uuid>,
    screen_name: Option<String>,
}

pub async fn set_screen_on_monitor(db: &Database, device_id: uuid::Uuid, identifier: String, screen_id: uuid::Uuid) -> color_eyre::Result<()> {
    sqlx::query(include_str!("set_screen_on_monitor.sql"))
        .bind(device_id)
        .bind(&identifier)
        .bind(screen_id)
        .execute(db.connection.as_ref())
        .await?;

    Ok(())
}

pub async fn register_device(db: &Database, entity: DeviceEntity) -> color_eyre::Result<()> {
    sqlx::query(include_str!("register_device.sql"))
        .bind(&entity.id)
        .bind(&entity.hostname)
        .bind(&entity.ip.to_string())
        .bind(&entity.version.major)
        .bind(&entity.version.minor)
        .bind(&entity.version.patch)
        .execute(db.connection.as_ref())
        .await?;

    for monitor in entity.monitors {
        sqlx::query(include_str!("register_device_monitor.sql"))
            .bind(&entity.id)
            .bind(&monitor.identifier)
            .bind(&monitor.width)
            .bind(&monitor.height)
            .execute(db.connection.as_ref())
            .await?;
    }

    Ok(())
}

pub async fn update_device(db: &Database, entity: DeviceEntity) -> color_eyre::Result<()> {
    sqlx::query(include_str!("update_device.sql"))
        .bind(&entity.hostname)
        .bind(&entity.ip.to_string())
        .bind(&entity.version.major)
        .bind(&entity.version.minor)
        .bind(&entity.version.patch)
        .bind(&entity.id)
        .execute(db.connection.as_ref())
        .await?;
    
    let devices = fetch_all_devices(db).await?;
    let monitors = devices.into_iter()
        .find(|d| d.id == entity.id)
        .into_iter()
        .flat_map(|d| d.monitors)
        .map(|monitor| monitor.identifier)
        .collect::<HashSet<_>>();

    for monitor in entity.monitors.into_iter().filter(|m| !monitors.contains(&m.identifier)) {
        sqlx::query(include_str!("register_device_monitor.sql"))
            .bind(&monitor.device_id)
            .bind(&monitor.identifier)
            .bind(&monitor.width)
            .bind(&monitor.height)
            .execute(db.connection.as_ref())
            .await?;
    }

    Ok(())
}

pub async fn delete_device(db: &Database, device_id: uuid::Uuid) -> color_eyre::Result<()> {
    sqlx::query(include_str!("delete_device.sql"))
        .bind(device_id)
        .execute(db.connection.as_ref())
        .await?;

    Ok(())
}

pub async fn rename_device(db: &Database, device_id: uuid::Uuid, name: &str) -> color_eyre::Result<()> {
    sqlx::query(include_str!("rename_device.sql"))
        .bind(name)
        .bind(device_id)
        .execute(db.connection.as_ref())
        .await?;

    Ok(())
}
