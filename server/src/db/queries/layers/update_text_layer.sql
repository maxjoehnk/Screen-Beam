update text_layers
set text               = ?2,
    font               = ?3,
    font_size          = ?4,
    line_height        = ?5,
    x                  = ?6,
    y                  = ?7,
    color_red          = ?8,
    color_green        = ?9,
    color_blue         = ?10,
    color_alpha        = ?11,
    shadow_offset_x    = ?12,
    shadow_offset_y    = ?13,
    shadow_color_red   = ?14,
    shadow_color_green = ?15,
    shadow_color_blue  = ?16,
    shadow_color_alpha = ?17,
    text_alignment     = ?18,
    font_weight        = ?19,
    italic             = ?20,
    layer_label        = ?21
where layer_id = ?1;
