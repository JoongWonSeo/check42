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