create table devices
(
    id            blob    not null
        constraint devices_pk
            primary key,
    name          text,
    hostname      text    not null,
    ip            text    not null,
    version_major integer not null,
    version_minor integer not null,
    version_patch integer not null
);

create table device_monitors
(
    device_id  blob    not null,
    identifier text    not null,
    width      integer not null,
    height     integer not null,
    screen_id  blob
        constraint device_monitors_screens_id_fk
            references screens (id)
            on delete set null,
    constraint device_monitors_pk
        primary key (device_id, identifier)
);

create table screens
(
    id   blob not null
        constraint screens_pk
            primary key,
    name text not null
);

create table slides
(
    id   blob not null
        constraint slides_pk
            primary key,
    name text not null
);

create table screen_slides
(
    screen_id blob not null
        constraint screen_slides_screen_id_fk
            references screens (id),
    slide_id  blob not null
        constraint screen_slides_slides_id_fk
            references slides (id),
    constraint screen_slides_pk
        primary key (screen_id, slide_id)
);

create table image_layers
(
    layer_id blob not null
        constraint image_layers_pk
            primary key,
    slide_id blob not null
        constraint image_layers_slides_id_fk
            references slides,
    image_data blob,
    content_type text
);

create table text_layers
(
    layer_id           blob    not null
        constraint text_layers_pk
            primary key,
    slide_id           blob    not null
        constraint text_layers_slides_id_fk
            references slides,
    text               text    not null,
    font_size          integer not null,
    font               text    not null,
    x                  integer not null,
    y                  integer not null,
    line_height        integer,
    color_red          integer not null,
    color_green        integer not null,
    color_blue         integer not null,
    color_alpha        integer not null,
    shadow_offset_x    integer,
    shadow_offset_y    integer,
    shadow_color_red   integer,
    shadow_color_green integer,
    shadow_color_blue  integer,
    shadow_color_alpha integer,
    text_alignment     integer default 0 not null
);

