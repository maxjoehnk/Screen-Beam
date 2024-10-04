use std::fmt::Display;
use std::net::IpAddr;
use sqlx::FromRow;
use super::ScreenEntity;

#[derive(Debug, Clone, PartialEq, Eq, FromRow)]
pub struct DeviceEntity {
    pub id: uuid::Uuid,
    pub name: Option<String>,
    pub ip: IpAddr,
    pub hostname: String,
    #[sqlx(flatten)]
    pub version: DeviceVersion,
    pub monitors: Vec<DeviceMonitorEntity>,
}

#[derive(Debug, Clone, PartialEq, Eq, FromRow)]
pub struct DeviceVersion {
    pub major: u32,
    pub minor: u32,
    pub patch: u32,
}

impl Display for DeviceVersion {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}.{}.{}", self.major, self.minor, self.patch)
    }
}

#[derive(Debug, Clone, PartialEq, Eq, FromRow)]
pub struct DeviceMonitorEntity {
    pub device_id: uuid::Uuid,
    pub identifier: String,
    pub width: u32,
    pub height: u32,
    pub screen_id: Option<uuid::Uuid>,
    #[sqlx(skip)]
    pub screen: Option<ScreenEntity>
}
