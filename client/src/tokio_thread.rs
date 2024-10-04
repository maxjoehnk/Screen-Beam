use std::future::Future;

pub fn spawn_tokio_thread<F: Future<Output=color_eyre::Result<()>>>(f: impl FnOnce() -> F + Send + 'static) {
    std::thread::spawn(|| {
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        if let Err(err) = rt.block_on(f()) {
            tracing::error!(error = ?err, "Error in tokio thread");

            std::process::exit(1);
        }
    });
}
