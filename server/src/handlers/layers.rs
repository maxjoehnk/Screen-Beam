use axum::body::Bytes;
use axum::BoxError;
use futures::{Stream, TryStreamExt};
use tokio::io;
use tokio::io::AsyncReadExt;
use tokio_util::io::StreamReader;

use digital_signage_api::{LayerId, SlideId};

use crate::db::{Database, entities::ImageLayerData, queries};

pub async fn read_image(db: &Database, layer_id: LayerId) -> color_eyre::Result<Option<ImageLayerData>> {
    let image_data = queries::fetch_image_layer_data(db, layer_id.into()).await?;

    Ok(image_data)
}

pub async fn upload_image<S, E>(db: &Database, slide_id: SlideId, layer_id: LayerId, data: S, content_type: String) -> color_eyre::Result<()>
    where
        S: Stream<Item=Result<Bytes, E>>,
        E: Into<BoxError>,
{
    let stream_reader = StreamReader::new(data.map_err(|err| io::Error::new(io::ErrorKind::Other, err)));
    futures::pin_mut!(stream_reader);
    let mut buffer = Vec::new();
    let mut read_bytes = stream_reader.read_buf(&mut buffer).await?;
    while read_bytes > 0 {
        read_bytes = stream_reader.read_buf(&mut buffer).await?;
    }

    queries::insert_image_layer_data(db, slide_id.into(), layer_id.into(), buffer, content_type, None).await?;

    Ok(())
}
