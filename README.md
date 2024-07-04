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
| Package name | Why used | Code |
| ------ | ------------------------------ | ------ |
| `sqflite` | This is a Flutter plugin for SQLite, providing a local database solution for storing structured data |<pre lang="yaml">  dependencies:&#13;    sqflite: ^2.3.3+1</pre>|
| `sqflite_common_ffi_web` | This package is used to support sqflite on web platforms using FFI (Foreign Function Interface), enabling SQLite database operations in web-based Flutter applications. |<pre lang="yaml">  dependencies:&#13;    sqflite_common_ffi_web: '>=0.1.0-dev.1'</pre>|
| `data_table_2` | This package offers enhanced data table functionalities, improving upon Flutter's built-in DataTable widget with additional features and customizations. |<pre lang="yaml">  dependencies:&#13;    data_table_2: ^2.5.12</pre>|
| `get_it` | A simple service locator for Dart and Flutter projects, facilitating dependency injection to manage and access instances of classes or services. |<pre lang="yaml">  dependencies:&#13;    get_it: ^7.7.0</pre>|
| `path & path_provider` |These packages are used for handling file system paths and providing platform-specific locations (like temporary and persistent storage directories) in Flutter applications.|<pre lang="yaml">  dependencies:&#13;    path: ^1.8.0&#13;    path_provider: ^2.0.2</pre>|
| `permission_handler` |  Simplifies handling runtime permissions in Flutter, allowing the application to request and check permissions easily. |<pre lang="yaml">  dependencies:&#13;    permission_handler: ^10.2.0</pre>|
| `flutter_launcher_icons` | This package automates the process of updating app launcher icons across different platforms in a Flutter project. |<pre lang="yaml">  dependencies:&#13;    flutter_launcher_icons: ^0.13.1</pre>|
| `intl` |  Provides internationalization and localization support in Flutter applications, offering tools to format dates, numbers, and strings according to different locales. |<pre lang="yaml">  dependencies:&#13;    intl: ^0.19.0</pre>|
| `get` | A state management solution that helps in managing state across Flutter widgets and simplifies reactive programming patterns. |<pre lang="yaml">  dependencies:&#13;    get: ^4.4.6</pre>|

to add web support to an existing sqflite application:
```dart
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

 var path = '/my/db/path';
 if (kIsWeb) {
  // Change default factory on the web
  databaseFactory = databaseFactoryFfiWeb;
  path = 'my_web_web.db';
 }
 
 // open the database
 var db = openDatabase(path);

```

## Conclusion
Market Manager leverages these packages to provide a comprehensive, efficient, and user-friendly mobile application for market administrators. By utilizing local database capabilities, enhanced data presentation, dependency management, permission handling, and internationalization support, the application ensures seamless operation and effective management of market activities on both mobile and web platforms.

This documentation serves to outline the application's purpose, highlight key functionalities enabled by the chosen packages, and emphasize their role in delivering a reliable and scalable solution for market management.
