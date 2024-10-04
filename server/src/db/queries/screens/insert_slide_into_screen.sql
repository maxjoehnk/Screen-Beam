insert into screen_slides (screen_id, slide_id, ordering)
VALUES (?1, ?2, (select max(ordering) + 1 from screen_slides where screen_id = ?1));
