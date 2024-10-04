select *, (select count(*) from screen_slides where slide_id = id) as screen_count from slides
