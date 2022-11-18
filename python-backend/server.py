import sqlite3
import json
from flask import Flask, jsonify, request


# connect to database
con = sqlite3.connect('file:database.db?mode=ro', uri=True, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES, check_same_thread=False)
con.set_trace_callback(print)
cur = con.cursor()

# create the flask app
app = Flask(__name__)

# define the API endpoints
@app.route('/')
def index():
    return jsonify({'name': 'alice',
                    'email': 'alice@outlook.com'})

@app.route('/search')
def search():
    # get url parameters
    g = request.args.get
    
    # create query constraints based on given parameters
    conds_args = list(filter(lambda pair: pair[1] is not None, [
        ('o.price >= ?', g('price_min')),
        ('o.price <= ?', g('price_max')),
        ('o.outbounddepartureairport = ?', g('airport')),
    ]))

    # build query
    query = f'''
SELECT DISTINCT h.name, o.price, o.departuredate, o.returndate, o.roomtype
FROM hotels as h INNER JOIN offers as o ON h.id = o.hotelid
WHERE {' AND '.join([c for c, _ in conds_args]) if len(conds_args)>0 else 'TRUE'}
LIMIT 100
'''

    # execute query
    results = cur.execute(query, [a for _, a in conds_args]).fetchall()
    results = [{
        'hotel': hotel, 'price': price, 'dep': dep, 'ret': ret, 'room': room
        } for hotel, price, dep, ret, room in results]
    return jsonify(results)
