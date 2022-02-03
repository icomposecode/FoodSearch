# FoodSearch
Sample app for Noom's coding interview round which allows users to search for the food items based on their search query

# Assumptions
App was developed with following assumptions in mind

- Backend API only supports searching in English
- No focus on the UI was given except for the basic functionality as per the requirements
- No filteration of characters is done at the client side, the app continues to send all the characters typed by the user to the server when making the API request

# Improvements for future
- App should handle errors using a more better UI approach for production app
- Should add unit tests for testing out the business logic of the app
- Should support voice search
- Should support detail view with Food details
- Should use pattern matching to avoid user typing the wildcard or other characters which are not in plain English
