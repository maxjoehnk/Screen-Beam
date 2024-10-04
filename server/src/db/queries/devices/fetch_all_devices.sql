SELECT devices.id            as device_id,
       devices.name          as device_name,
       devices.ip            as device_ip,
       devices.hostname      as device_hostname,
       devices.version_major as device_version_major,
       devices.version_minor as device_version_minor,
       devices.version_patch as device_version_patch,
       monitor.identifier    as monitor_identifier,
       monitor.width         as monitor_width,
       monitor.height        as monitor_height,
       monitor.screen_id     as monitor_screen_id,
       screen.id             as screen_id,
       screen.name           as screen_name

from devices
         left join device_monitors monitor on devices.id = monitor.device_id
         left join screens screen on monitor.screen_id = screen.id
