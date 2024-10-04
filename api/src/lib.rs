use std::fmt::Display;
use serde_derive::{Deserialize, Serialize};
use std::net::IpAddr;

pub mod mdns;

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Device {
    pub id: DeviceId,
    pub name: Option<String>,
    pub hostname: String,
    pub address: IpAddr,
    pub version: String,
    pub monitors: Vec<DeviceMonitor>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct DeviceMonitor {
    pub identifier: String,
    pub width: u32,
    pub height: u32,
    pub screen: Option<Screen>,
}

#[derive(Debug, Default, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[repr(transparent)]
#[serde(transparent)]
pub struct DeviceId(uuid::Uuid);

impl DeviceId {
    pub fn new() -> Self {
        Self(uuid::Uuid::new_v4())
    }
}

impl From<uuid::Uuid> for DeviceId {
    fn from(value: uuid::Uuid) -> Self {
        Self(value)
    }
}

impl From<DeviceId> for uuid::Uuid {
    fn from(value: DeviceId) -> uuid::Uuid {
        value.0
    }
}

impl PartialEq<uuid::Uuid> for DeviceId {
    fn eq(&self, other: &uuid::Uuid) -> bool {
        self.0 == *other
    }
}

impl Display for DeviceId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0.as_hyphenated())
    }
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Screen {
    pub id: ScreenId,
    pub name: String,
    pub slides: Vec<Slide>,
    pub monitor_usage: usize,
}

#[derive(Debug, Default, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[repr(transparent)]
#[serde(transparent)]
pub struct ScreenId(uuid::Uuid);

impl ScreenId {
    pub fn new() -> Self {
        Self(uuid::Uuid::new_v4())
    }
}

impl From<uuid::Uuid> for ScreenId {
    fn from(value: uuid::Uuid) -> Self {
        Self(value)
    }
}

impl From<ScreenId> for uuid::Uuid {
    fn from(value: ScreenId) -> uuid::Uuid {
        value.0
    }
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Slide {
    pub id: SlideId,
    pub name: String,
    pub layers: Vec<SlideLayer>,
    pub screen_usage: usize,
}

#[derive(Debug, Default, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[repr(transparent)]
#[serde(transparent)]
pub struct SlideId(uuid::Uuid);

impl SlideId {
    pub fn new() -> Self {
        Self(uuid::Uuid::new_v4())
    }
}

impl From<uuid::Uuid> for SlideId {
    fn from(value: uuid::Uuid) -> Self {
        Self(value)
    }
}

impl From<SlideId> for uuid::Uuid {
    fn from(value: SlideId) -> uuid::Uuid {
        value.0
    }
}

impl Display for SlideId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0.as_hyphenated())
    }
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum SlideLayer {
    Image(ImageLayer),
    Text(TextLayer),
}

#[derive(Debug, Default, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[repr(transparent)]
#[serde(transparent)]
pub struct LayerId(uuid::Uuid);

impl LayerId {
    pub fn new() -> Self {
        Self(uuid::Uuid::new_v4())
    }
}

impl From<uuid::Uuid> for LayerId {
    fn from(value: uuid::Uuid) -> Self {
        Self(value)
    }
}

impl From<LayerId> for uuid::Uuid {
    fn from(value: LayerId) -> uuid::Uuid {
        value.0
    }
}

impl Display for LayerId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0.as_hyphenated())
    }
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ImageLayer {
    pub id: LayerId,
    pub label: Option<String>,
    pub content_type: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TextLayer {
    pub id: LayerId,
    pub label: Option<String>,
    pub x: i32,
    pub y: i32,
    pub text: String,
    pub font: String,
    pub font_size: u32,
    pub line_height: Option<u32>,
    pub color: Color,
    pub shadow: Option<Shadow>,
    #[serde(default = "default_font_weight")]
    pub font_weight: u16,
    #[serde(default)]
    pub italic: bool,
    #[serde(default)]
    pub alignment: TextAlignment,
}

fn default_font_weight() -> u16 {
    400
} 

#[derive(Default, Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
#[repr(u8)]
pub enum TextAlignment {
    #[default]
    Start,
    Center,
    End
}

impl TryFrom<u8> for TextAlignment {
    type Error = ();

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(Self::Start),
            1 => Ok(Self::Center),
            2 => Ok(Self::End),
            _ => Err(()),
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub struct Color {
    pub red: u8,
    pub green: u8,
    pub blue: u8,
    pub alpha: u8,
}

impl Color {
    const WHITE: Self = Self::new(255, 255, 255, 255);

    const fn new(red: u8, green: u8, blue: u8, alpha: u8) -> Self {
        Self { red, green, blue, alpha }
    }
}

impl Default for Color {
    fn default() -> Self {
        Self::WHITE
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Shadow {
    pub x_offset: i32,
    pub y_offset: i32,
    pub color: Color,
}

#[derive(Debug, Clone, Deserialize)]
pub struct AddScreenRequest {
    pub name: String,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AddSlideToScreenRequest {
    pub slide_id: SlideId,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ReorderSlidesRequest {
    pub old_index: usize,
    pub new_index: usize,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SetScreenOnMonitorRequest {
    pub screen_id: ScreenId,
}

#[derive(Debug, Clone, Deserialize)]
pub struct AddSlideRequest {
    pub name: String,
    pub id: Option<SlideId>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RegisterDeviceRequest {
    pub hostname: String,
    pub address: IpAddr,
    pub version: String,
    pub monitors: Vec<DeviceMonitorInfo>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct DeviceMonitorInfo {
    pub identifier: String,
    pub width: u32,
    pub height: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RenameDeviceRequest {
    pub name: String,
}
