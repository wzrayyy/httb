from locust import HttpUser, task
class RootUser(HttpUser):
    @task
    def root(self):
        self.client.get("/")
