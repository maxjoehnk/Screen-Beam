update device_monitors
set screen_id = ?3
where device_id = ?1
  and identifier = ?2
