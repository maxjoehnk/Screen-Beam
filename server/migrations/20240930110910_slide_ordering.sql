alter table screen_slides
    add ordering integer not null default 0;

with RankedSlides as (
    select
        screen_id,
        slide_id,
        ROW_NUMBER() over (partition by screen_id order by slide_id) - 1 as ordering
    from
        screen_slides
)
update screen_slides
set ordering = (
    select ordering
    from RankedSlides
    where RankedSlides.screen_id = screen_slides.screen_id
      and RankedSlides.slide_id = screen_slides.slide_id
);
