update image_layers
set image_data   = ?2,
    content_type = ?3,
    layer_label = ?4
where layer_id = ?1;

