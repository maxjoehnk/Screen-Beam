use sqlx::FromRow;

#[derive(Debug, Clone, PartialEq, Eq, FromRow)]
pub struct ScreenEntity {
    pub id: uuid::Uuid,
    pub name: String,
}

impl ScreenEntity {
    pub fn new(name: String) -> Self {
        Self {
            id: uuid::Uuid::new_v4(),
            name,
        }
    }
}
