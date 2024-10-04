use zeroconf::ServiceType;

pub fn service_type() -> color_eyre::Result<ServiceType> {
    let service_type = ServiceType::new("digital_signage", "tcp")?;

    Ok(service_type)
}
