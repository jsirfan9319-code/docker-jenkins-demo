from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
   return "Hello from AWS DevOps! Version 2 - Automatic CI/CD deployment is working!"
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
