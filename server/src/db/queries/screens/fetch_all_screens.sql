SELECT screens.id as screen_id, screens.name as screen_name, s.id as slide_id, s.name as slide_name, ss.ordering as ordering, (select count(*) from device_monitors where screen_id = screens.id) as assigned_monitor_count
from screens
         left join screen_slides ss on screens.id = ss.screen_id
        left join slides s on s.id = ss.slide_id;
