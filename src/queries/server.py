import datetime
import os

import jwt
import pandas as pd
from flask import Flask, request
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text

server = Flask(__name__)

# config
host = os.environ.get("MYSQL_HOST")
username = os.environ.get("MYSQL_USER")
password = os.environ.get("MYSQL_PASSWORD")
database_name = os.environ.get("MYSQL_DB")
port = os.environ.get("MYSQL_PORT")
server.config[
    "SQLALCHEMY_DATABASE_URI"
] = f"mysql+pymysql://{username}:{password}@{host}:{port}/{database_name}"

db = SQLAlchemy(server)

quer1_text = """\
SELECT departments.department,
       jobs.job,
       SUM(CASE WHEN SELECT STR_TO_DATE(employees.datetime, "%Y %M %d") BETWEEN "2021"
"""


@server.route("/query1", methods=["POST"])
def login():
    auth = request.authorization
    if not auth:
        return "missing credentials", 401

    # check db for username and password
    res = db.session.execute(
        text(),
    )

    rows = res.all()

    if len(rows) > 0:
        user_row = rows[0]
        email = user_row[0]
        password = user_row[1]

        if auth.username != email or auth.password != password:
            return "invalid credentials", 401
        else:
            return createJWT(auth.username, os.environ.get("JWT_SECRET"), True)
    else:
        return "invalid credentials", 401


@server.route("/validate", methods=["POST"])
def validate():
    encoded_jwt = request.headers["Authorization"]

    if not encoded_jwt:
        return "missing credentials", 401

    encoded_jwt = encoded_jwt.split(" ")[1]

    try:
        decoded = jwt.decode(
            encoded_jwt, os.environ.get("JWT_SECRET"), algorithms=["HS256"]
        )
    except:
        return "not authorized", 403

    return decoded, 200


def createJWT(username, secret, authz):
    return jwt.encode(
        {
            "username": username,
            "exp": datetime.datetime.now(tz=datetime.timezone.utc)
            + datetime.timedelta(days=1),
            "iat": datetime.datetime.utcnow(),
            "admin": authz,
        },
        secret,
        algorithm="HS256",
    )


if __name__ == "__main__":
    server.run(host="0.0.0.0", port=5000)
