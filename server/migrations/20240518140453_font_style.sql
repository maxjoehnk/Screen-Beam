-- Add migration script here
alter table text_layers
    add font_weight integer default 400 not null;

alter table text_layers
    add italic integer default 0 not null;

