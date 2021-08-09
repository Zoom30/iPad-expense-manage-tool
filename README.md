#  Important notes

## Default Sort - most often selected
The app sorts the categories by most often selected by default. To achieve that, the entity "Category" has an additional attribute called "selected" of type Int16. The app fetches data with decreasing number of "selected", so that the most selected category shall be fetched first and placed on the first cell in the tableview and so on. 

Each time the user clicks a category, the "selected" counter of that specific category increases by 1.


## Attribute "date" in Category entity
Everytime a category is added, the date in format "Date().timeIntervalSince1970" of the category is registered. This attribute was added to serve a unique identifier for the categories and could be used in sortDescriptors and Predicate rules if needed. It is not visible to the user.

