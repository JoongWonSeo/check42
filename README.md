# CHECK42

## Description
My 2-day-implementation of the Check24 Holiday Challenge for the GenDev Scholarship. It has minimal elements needed to get the entire tech stack working:

- Flutter frontend: Simple phone app with search function, REST API request and fetch from the backend.
- Flask API: Handles REST API requests and responses.
- Python: Callbacks from the Flask layer to parse requests, create SQL queries, and encode the result as JSON.
- Sqlite: Simple SQL database that saves the actual offers and hotels.


Each folders for the frontend and backend contain more detailed READMEs.


## TODOS

Due to time-constraints, there are several missing features:
- Group by hotel view, the 'see offers' button doesn't show any second view currently.
- The searched offers result list doesn't visualize some fetched data such as flight date (it's trivial but I was lazy).
- Optimizing the SQL DB (refactoring, indexes, manual caching etc.) for faster response (for queries that require search of the entire 73M rows, it takes upto 30s on my laptop).
- The URL to the backend server from the Flutter app is currently hardcoded (just set the 1 variable).
- There are probably some bugs in the UI, especially for various aspect-ratios.


## Screenshots

https://user-images.githubusercontent.com/30022460/202928463-7513213f-8f0c-4b46-8469-4dcea485bad5.mp4

<img src="https://user-images.githubusercontent.com/30022460/202928444-74840579-2d26-46ef-89fb-bcc144aa872a.jpg" alt="ss1" width="330"/>    <img src="https://user-images.githubusercontent.com/30022460/202928449-c8852d30-b087-41ac-bcd4-40d1a1de8426.jpg" alt="ss2" width="330"/>    <img src="https://user-images.githubusercontent.com/30022460/202928451-8b9835da-08df-46c9-8138-b53d4e4960c1.jpg" alt="ss3" width="330"/>

