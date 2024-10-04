delete
from text_layers
where slide_id = ?1
  and layer_id = ?2;
delete
from image_layers
where slide_id = ?1
  and layer_id = ?2;
