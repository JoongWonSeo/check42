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

## Create SQL Index to (significantly) speed up queries
```
python query.py "CREATE INDEX IF NOT EXISTS idx_price ON offers(price);"
python query.py "CREATE INDEX IF NOT EXISTS idx_departuredate ON offers(departuredate);"
python query.py "CREATE INDEX IF NOT EXISTS idx_returndate ON offers(returndate);"
python query.py "CREATE INDEX IF NOT EXISTS idx_category_stars ON hotels(category_stars);"
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


## Example queries
http://127.0.0.1:5000/search?price_max=310&airports=[%22MUC%22,%22DUS%22,%22FRA%22]&departure_after=2022-10-10&departure_before=2022-10-11

More specific time (see [sqlite time](https://www.sqlite.org/lang_datefunc.html)):
http://127.0.0.1:5000/search?price_max=310&airports=[%22MUC%22,%22DUS%22,%22FRA%22]&departure_after=2022-10-10T15:00&departure_before=2022-10-11T15:30

http://127.0.0.1:5000/search?price_max=310&airports=[%22MUC%22]&adults=1&children=0&departure_after=2022-10-10&departure_before=2022-10-15


## Some observations about the given dataset

### offers.csv
- It's huge: 72353411 rows and >14GB!
- On my laptop, a query that requires a search through the entire DB with python and sqlite3 takes around 30s
- Since the dataset is only Mallorca, inbounddepartureairport = outboundarrivalairport = PMI for all rows
- inboundarrivalairport = outbounddepartureairport for all rows, which makes sense I guess
- should definitely make an index based on e.g. price so that you can sort by price and also for date for range search!