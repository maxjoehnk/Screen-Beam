use std::sync::Arc;

use sqlx::SqlitePool;

pub mod entities;
pub mod queries;

#[derive(Clone)]
pub struct Database {
    pub connection: Arc<SqlitePool>,
}

impl Database {
    pub async fn connect() -> color_eyre::Result<Self> {
        let connection = SqlitePool::connect("sqlite://db.sqlite?mode=rwc").await?;

        sqlx::migrate!().run(&connection).await?;

        Ok(Database {
            connection: Arc::new(connection)
        })
    }
}
