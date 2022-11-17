import sqlite3
import json
from flask import Flask, jsonify, request


# connect to database
con = sqlite3.connect('file:database.db?mode=ro', uri=True, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
cur = con.cursor()

# create the flask app
app = Flask(__name__)

# define the API endpoints
@app.route('/')
def index():
    return jsonify({'name': 'alice',
                    'email': 'alice@outlook.com'})

@app.route('/search')
def index():
    price = request.args.get('price')
    return jsonify({'name': 'alice',
                    'email': 'alice@outlook.com'})
