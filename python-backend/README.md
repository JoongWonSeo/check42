# Python Backend

## Import the CSV to SQLite3 database

```
python create_db.py <csv> <table_name> <batch_size>
```

For hotels.csv:
```
python create_db.py hotels.csv hotels 1000000
```

For offers.csv (*WARNING: WILL TAKE A LONG TIME*):
```
python create_db.py offers.csv offers 1000000
```


## Start the REST API Server

Debug (*WARNING: DEBUG MODE HAS ARBITRARY CODE EXECUTION*):
```
flask --app server --debug run
```

Non-debug:
```
flask --app server run
```


## Some observations about the given dataset

### offers.csv
- It's huge: 72353411 rows and >14GB!
- On my laptop, a query that requires a search through the entire DB with python and sqlite3 takes around 30s
- Since the dataset is only Mallorca, inbounddepartureairport = outboundarrivalairport = PMI for all rows
- inboundarrivalairport = outbounddepartureairport for all rows, which makes sense I guess
- should definitely make an index based on e.g. price so that you can sort by price and also for date for range search!