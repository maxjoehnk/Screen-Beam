use std::any::Any;
use std::sync::Arc;
use std::thread;
use std::time::Duration;

use zeroconf::{MdnsBrowser, ServiceDiscovery};
use zeroconf::prelude::*;

use digital_signage_api::mdns::service_type;

const POLL_TIMEOUT_SECS: u64 = 1;

pub fn discover() -> color_eyre::Result<flume::Receiver<String>> {
    let (sender, receiver) = flume::bounded(1);

    let service_type = service_type()?;
    thread::Builder::new()
        .name("Session MDNS Discovery".into())
        .spawn(|| {
            let mut browser = MdnsBrowser::new(service_type);
            browser.set_context(Box::new(sender));

            browser.set_service_discovered_callback(Box::new(on_service_discovered));

            let event_loop = browser.browse_services().unwrap();
            loop {
                event_loop
                    .poll(Duration::from_secs(POLL_TIMEOUT_SECS))
                    .unwrap();
                thread::sleep(Duration::from_secs(POLL_TIMEOUT_SECS));
            }
        })?;

    Ok(receiver)
}

fn on_service_discovered(
    result: zeroconf::Result<ServiceDiscovery>,
    context: Option<Arc<dyn Any>>,
) {
    tracing::debug!("service discovered: {:?}", result);
    if let Ok(service) = result {
        let sender = context
            .as_ref()
            .unwrap()
            .downcast_ref::<flume::Sender<String>>()
            .unwrap();
        if let Err(err) = sender.send(format!("http://{}:{}", service.host_name(), service.port())) {
            tracing::error!(error = ?err, "Error sending server url");
        }
    }
}
