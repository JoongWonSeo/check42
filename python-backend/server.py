import sqlite3
import json
from flask import Flask, jsonify, request
from itertools import chain


# connect to database
con = sqlite3.connect('file:database.db?mode=ro', uri=True,
                      detect_types=sqlite3.PARSE_DECLTYPES | sqlite3.PARSE_COLNAMES, check_same_thread=False)
con.set_trace_callback(print)

# create the flask app
app = Flask(__name__)

# define the API endpoints


@app.route('/')
def index():
    return 'Hello, World!'


@app.route('/search')
def search():
    cur = con.cursor()

    # get url parameters
    g = request.args.get  # get raw parameter

    def j(x):  # get parameter as dict, list, string, int, or float
        try:
            return json.loads(request.args.get(x))
        except Exception:
            return None

    # ? placeholders for each item in list
    def ph(x): return '(' + ('' if x is None else ','.join(['?']*len(x))) + ')'

    # create query constraints based on given parameters
    airports = j('airports')  # list of airports
    print(f"{g('airports')} ({type(g('airports'))}) -> {airports}")
    conds_args = list(filter(lambda pair: pair[1] is not None, [
        ('o.departuredate >= ?', g('departure_after')),
        ('o.departuredate <= ?', g('departure_before')),
        ('o.returndate >= ?', g('return_after')),
        ('o.returndate <= ?', g('return_before')),
        ('o.countadults = ?', g('adults')),
        ('o.countchildren = ?', g('children')),
        ('o.price >= ?', g('price_min')),
        ('o.price <= ?', g('price_max')),
        (f"o.outbounddepartureairport IN {ph(airports)}", airports),
    ]))
    # sort by
    sort_by = g('sort_by', None)  # either 'price' or 'rating' or None

    # build query
    query = f'''
SELECT DISTINCT h.name, o.outbounddepartureairport, o.price, o.departuredate, o.returndate, o.mealtype, o.oceanview, o.roomtype
FROM hotels as h INNER JOIN offers as o ON h.id = o.hotelid
WHERE {' AND '.join([c for c, _ in conds_args]) if len(conds_args)>0 else 'TRUE'}
{('ORDER BY' + (' o.price' if sort_by=='price' else ' h.category_stars DESC')) if sort_by is not None else ''}
LIMIT 100
'''
    args = tuple(chain.from_iterable(
        a if type(a) is list else [a] for _, a in conds_args))
    print(args)

    # execute query
    results = cur.execute(query, args).fetchall()
    results = {'results': [{
        'hotel': hotel,'airport': airport, 'price': price,
        'dep': dep, 'ret': ret, 'adults': int(g('adults', '0')),
        'children': int(g('children', '0')), 'meal': meal, 'ocean': ocean, 'room': room
    } for hotel, airport, price, dep, ret, meal, ocean, room in results]}

    cur.close()
    return jsonify(results)


@app.route('/test')
def test():
    for param in request.args:
        print(param, request.args.get(param))

    return jsonify(request.args)
