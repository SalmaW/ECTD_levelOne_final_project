# Market Manager App

## Purpose of Application
Market Manager is responsible for managing a market throughout the phone. Using database to handle the market data such as Categories, Products, Orders, Currency, Clients, OrderItems and … etc. And the financial data such as Sale operation and the History of Sales of the market.

The application replaces traditional paper-based methods, reducing waste and providing convenient access to essential data anytime, anywhere. It also supports currency exchange rates for EGP, USD, and EUR, allowing the Market Owner to switch currencies with a single click.

To ensure data integrity, the application includes a feature that saves data to the latest version of the database in the device's local storage, contingent on user permission. Users can also choose not to restore data from previous sessions, in which case all previous data will be wiped.

## Application Usability
The Market Manager app offers the following functionalities to market owners:
  + Home Screen: Access to the five main screens: Category, Client, Product, Sale Operations, and All Sales.
  + Category Management: Create and update categories, with all associated products reflecting changes.
  + Client Management: Create and update clients, necessary for proceeding with sales.
  + Product Management: Create and update products, each belonging to a specific category.
  + Sale Operations: Record sales, including specific items purchased by clients and apply discounts to the total receipt.
  + Sales History: View all past sales.

Users can delete categories, clients, products, and sales as needed, with the restriction that a category with products cannot be deleted until all related products are removed.

## Sorting and Filtering
To facilitate data management, the application includes Sort and Filter functions on various 
screens:
  + Category Screen: Sort by Category Name.
  + Clients Screen: Sort by Client Name or Email, and Filter by Address.
  + Products Screen: Sort by Product Name or Category Name, and Filter by Price or Category ID

## Used Packages
The following packages are used to build the Market Manager application:
| Package name | Code |
| ------ | ------ |
|  |```yaml|
| `sqflite` |<pre lang="json">  dependencies:&#13;    sqflite: ^2.3.3+1</pre>|
| 400    |Some text here|




