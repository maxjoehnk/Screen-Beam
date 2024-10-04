use url::Url;

pub struct ApiClient {
    client: reqwest::Client,
    base_url: Url,
}

impl ApiClient {
    pub fn new(base_url: Url) -> Self {
        Self {
            client: reqwest::Client::new(),
            base_url,
        }
    }

    pub async fn put(&self, path: &str, body: impl serde::Serialize) -> color_eyre::Result<reqwest::Response> {
        let res = self.client.put(self.base_url.join(path).unwrap())
            .json(&body)
            .send()
            .await?;

        Ok(res)
    }

    pub async fn post(&self, path: &str, body: impl serde::Serialize) -> color_eyre::Result<reqwest::Response> {
        let res = self.client.post(self.base_url.join(path).unwrap())
            .json(&body)
            .send()
            .await?;

        Ok(res)
    }

    pub async fn get(&self, path: &str) -> color_eyre::Result<reqwest::Response> {
        let res = self.client.get(self.base_url.join(path).unwrap())
            .send()
            .await?;

        Ok(res)
    }
}
