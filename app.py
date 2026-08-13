from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
  return "Hello from AWS DevOps! Version 3 - Automatic deployment is working!"
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
