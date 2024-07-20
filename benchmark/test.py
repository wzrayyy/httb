from flask import Flask

app = Flask('app')

@app.get("/")
def root():
    return "{}"
