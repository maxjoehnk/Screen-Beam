use std::thread;
use std::time::Duration;

use zeroconf::MdnsService;
use zeroconf::prelude::*;

use digital_signage_api::mdns::service_type;

const POLL_TIMEOUT_SECS: u64 = 1;

pub fn announce(port: u16) -> color_eyre::Result<()> {
    let service_type = service_type()?;
    thread::Builder::new()
        .name("Digital Signage MDNS Broadcast".into())
        .spawn(move || {
            let mut service = MdnsService::new(service_type, port);
            service.set_name("Digital Signage");

            let event_loop = service.register().unwrap();
            loop {
                event_loop.poll(Duration::from_secs(POLL_TIMEOUT_SECS)).unwrap();
                // poll doesn't sleep in avahi implementation
                #[cfg(target_os = "linux")]
                thread::sleep(Duration::from_secs(POLL_TIMEOUT_SECS));
            }
        })?;

    Ok(())
}
