SELECT layer_id, image_data, content_type, layer_label
from image_layers
where layer_id = ?1;
