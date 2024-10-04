delete from text_layers
where slide_id = ?1;
delete from image_layers
where slide_id = ?1;
delete from screen_slides
where slide_id = ?1;
delete from slides
where id = ?1;
