use std::sync::Arc;
use std::sync::atomic::AtomicBool;
use std::time::Duration;
use parking_lot::{Mutex, RwLock};
use digital_signage_api::{Screen, Slide, SlideId};

const DEFAULT_TRANSITION_TIME: Duration = Duration::from_secs(30);

pub struct SlidesState {
    current_slide: Arc<RwLock<Option<SlideId>>>,
    slides: Arc<Mutex<Vec<SlideId>>>,
    has_transitioned: Arc<AtomicBool>,
}

impl SlidesState {
    pub fn new() -> Self {
        Self {
            current_slide: Arc::new(RwLock::new(None)),
            slides: Arc::new(Mutex::new(Vec::new())),
            has_transitioned: Arc::new(AtomicBool::new(false)),
        }
    }

    pub fn get_current_slide<'a>(&self, screen: &'a Screen) -> Option<&'a Slide> {
        self.update_slides(screen);
        let slide_id = (*self.current_slide.read())?;

        screen.slides.iter().find(|slide| slide.id == slide_id)
    }

    pub fn take_has_transitioned(&self) -> bool {
        self.has_transitioned.swap(false, std::sync::atomic::Ordering::Relaxed)
    }

    fn update_slides(&self, screen: &Screen) {
        let mut slides = self.slides.lock();
        *slides = screen.slides.iter().map(|slide| slide.id).collect();
        let current_slide_id = { *self.current_slide.read() };
        match current_slide_id {
            Some(slide_id) if !slides.contains(&slide_id) => {
                tracing::debug!("Slide not found in new screen, resetting to first slide.");
                *self.current_slide.write() = slides.first().copied();
            }
            None => {
                tracing::debug!("No current slide, setting to first slide.");
                *self.current_slide.write() = slides.first().copied();
            }
            _ => {}
        }
        tracing::debug!("Updated slides");
    }

    pub fn spawn_timer(&self) {
        let current_slide = Arc::clone(&self.current_slide);
        let slides = Arc::clone(&self.slides);
        let has_transitioned = Arc::clone(&self.has_transitioned);
        std::thread::spawn(move || {
            loop {
                {
                    let slides = slides.lock();
                    let mut current_slide = current_slide.write();
                    if let Some(slide) = *current_slide {
                        let current_index = slides.iter().position(|slide_id| slide_id == &slide).unwrap();
                        let next_index = (current_index + 1) % slides.len();
                        *current_slide = Some(slides[next_index]);
                    }
                }
                has_transitioned.store(true, std::sync::atomic::Ordering::Relaxed);
                std::thread::sleep(DEFAULT_TRANSITION_TIME);
            }
        });
    }
}
