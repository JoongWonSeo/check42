# execute any sql query on the database
import sqlite3
import sys

con = sqlite3.connect('database.db', detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
cur = con.cursor()

# get query from CLI
if len(sys.argv) != 2:
    print('Usage: python query.py "<query>"')
    sys.exit(1)

query = sys.argv[1]

# execute query
print(cur.execute(query).fetchall())