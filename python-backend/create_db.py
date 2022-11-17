import sys
import csv
import sqlite3
from itertools import islice
from datetime import datetime, timezone

# preset datatype for the columns in the csv datasets:
# offers.csv: hotelid INTEGER,departuredate TIMESTAMP,returndate TIMESTAMP,countadults INTEGER,countchildren INTEGER,price INTEGER,inboundarrivaldatetime TIMESTAMP,outboundarrivaldatetime TIMESTAMP,oceanview BOOLEAN
# hotels.csv: id INTEGER,latitude REAL,longitude REAL,category_stars REAL
column_types = {
    # offers.csv
    "hotelid": "INTEGER",
    "departuredate": "TIMESTAMP",
    "returndate": "TIMESTAMP",
    "countadults": "INTEGER",
    "countchildren": "INTEGER",
    "price": "INTEGER",
    "inboundarrivaldatetime": "TIMESTAMP",
    "outboundarrivaldatetime": "TIMESTAMP",
    "oceanview": "BOOLEAN",
    # hotels.csv
    "id": "INTEGER PRIMARY KEY",
    "latitude": "REAL",
    "longitude": "REAL",
    "category_stars": "REAL",
}


# import the csv dataset into the database
def import_from_csv(con, cur, dataset_path, table_name, batch_size=1000, verbose=False):
    with open(dataset_path, encoding='utf-8-sig') as file:
        reader = csv.reader(file)

        # first create the table with the column names
        columns = next(reader)
        columns = [f"{c} {column_types.get(c, '')}".strip() for c in columns] # assign default types to the columns
        query = f"CREATE TABLE {table_name} ({', '.join(columns)});"
        if verbose:
            print(query)
        cur.execute(query)

        # remember the columns that are timestamps
        timestamp_columns = [i for i, column in enumerate(columns) if 'TIMESTAMP' in column]

        # remember the columns that are booleans
        boolean_columns = [i for i, column in enumerate(columns) if 'BOOLEAN' in column]

        # insert data in batches until the end of the file
        while True:
            rows = []
            for row in islice(reader, batch_size):
                # convert the timestamp columns to datetime objects, and convert them to UTC
                for c in timestamp_columns:
                    row[c] = datetime.fromisoformat(row[c]).astimezone(timezone.utc).replace(tzinfo=None)
                
                # convert the boolean columns to 0s and 1s
                for c in boolean_columns:
                    row[c] = 0 if row[c] == 'false' else 1

                rows.append(tuple(row))
            
            # check if we reached the end of the file
            if len(rows) == 0:
                break

            cur.executemany(f"INSERT INTO {table_name} VALUES ({', '.join(['?'] * len(columns))})", rows)
            con.commit()
            if verbose:
                print('#', end='', flush=True)
            

# call import_from_csv from CLI
if __name__ == "__main__":
    args = sys.argv[1:]
    if len(args) != 3:
        print("Usage: python create_db.py <dataset_path> <table_name> <batch_size>")
        sys.exit(1)

    con = sqlite3.connect("database.db", detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
    cur = con.cursor()
    import_from_csv(con, cur, args[0], args[1], int(args[2]), verbose=True)