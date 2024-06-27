import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class SqlHelper {
  Database? db;
  bool isDBInitialized = false;
  final String dbName = 'pos.db';

  // Initialize database
  Future<void> init() async {
    try {
      if (kIsWeb) {
        var factory = databaseFactoryFfiWeb;
        db = await factory.openDatabase('pos.db');
      } else {
        db = await openDatabase(
          'pos.db',
          version: 1,
          onCreate: (db, version) {
            print('Database created successfully');
          },
        );
      }
      isDBInitialized = true;
    } catch (e) {
      print('Error in creating db: $e');
    }
  }

  Future<void> getForeignKeys() async {
    await db!.rawQuery("PRAGMA foreign_keys = ON");
    var result = await db!.rawQuery("PRAGMA foreign_keys");
    print("foreign keys result: $result");
  }

  Future<bool> createTables() async {
    try {
      await getForeignKeys();
      var batch = db!.batch();

      batch.execute("""
        Create table if not exists Categories(
          id integer primary key,
          name text not null,
          description text not null
          ) 
          """);

      batch.execute("""
        Create table if not exists Products(
          id integer primary key,
          name text not null,
          description text not null,
          price double not null,
          stock integer not null,
          isAvailable boolean not null,
          image text,
          categoryId integer not null,
          foreign key(categoryId) references Categories(id)
          on delete restrict
          ) 
          """);

      batch.execute("""
        Create table if not exists Clients(
          id integer primary key,
          name text not null,
          email text,
          phone text,
          address text
          ) 
          """);

      batch.execute("""
        Create table if not exists Orders(
          id integer primary key,
          label text,
          totalPrice real,
          discount real,
          clientId integer not null,
          foreign key(clientId) references Clients(id)
          on delete restrict
          ) 
          """);

      batch.execute("""
        Create table if not exists orderProductItems(
          orderId integer,
          productId integer,
          productCount integer,
          foreign key(productId) references Products(id)
          on delete cascade
          ) 
          """);

      batch.execute("""
        CREATE TABLE if not exists exchangeRates (
          id INTEGER PRIMARY KEY,
          currency_from TEXT NOT NULL,
          currency_to TEXT NOT NULL,
          rate real NOT NULL
          )
          """);

      var result = await batch.commit();
      await insertInitialExchangeRates();
      print('results $result');
      return true;
    } catch (e) {
      print('Error in creating table: $e');
      return false;
    }
  }

  Future<int> getDependentProductCount(int categoryId) async {
    var result = await db!.rawQuery(
        'SELECT COUNT(*) FROM Products WHERE categoryId = ?', [categoryId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Backup database
  Future<bool> backupDatabase() async {
    try {
      // Request storage permission if not granted
      if (!(await Permission.storage.isGranted)) {
        var status = await Permission.storage.request();
        if (status != PermissionStatus.granted) {
          print('Permission denied for storage');
          return false;
        }
      }

      String path = await getDatabasePath();
      String backupPath = await getBackupDatabasePath();

      // Ensure the database file exists
      if (await File(path).exists()) {
        // Copy database file to backup path
        await File(path).copy(backupPath);
        print('Database backed up successfully');
        return true;
      } else {
        print('Original database file does not exist');
        return false;
      }
    } catch (e) {
      print('Error backing up database: $e');
      return false;
    }
  }

  // Restore database from backup
  Future<bool> restoreDatabase() async {
    try {
      // Request storage permission
      if (!(await Permission.storage.isGranted)) {
        var status = await Permission.storage.request();
        if (status != PermissionStatus.granted) {
          print('Permission denied for storage');
          return false;
        }
      }

      String path = await getDatabasePath();
      String backupPath = await getBackupDatabasePath();

      // Ensure the backup database file exists
      if (await File(backupPath).exists()) {
        // Copy backup file to original database path
        await File(backupPath).copy(path);
        print('Database restored successfully from backup');
        return true;
      } else {
        print('There is no Backup database file');
        return false;
      }
    } catch (e) {
      print('Error restoring database: $e');
      return false;
    }
  }

  // Get path for the database file
  Future<String> getDatabasePath() async {
    String databasesPath = await getDatabasesPath();
    return join(databasesPath, 'pos.db');
  }

  // Get path for the backup database file
  Future<String> getBackupDatabasePath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    return join(appDocDir.path, 'pos_backup.db');
  }

  // Show restore confirmation dialog
  Future<bool> _showRestoreConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Restore Database'),
              content: const Text(
                  'Do you want to restore the database from backup?'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                    if (isDBInitialized) {
                      await clearDatabase();
                    }
                    await createTables();
                  },
                ),
                TextButton(
                  child: const Text('Restore'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if dialog is dismissed
  }

  Future<void> clearDatabase() async {
    try {
      await db!.transaction((txn) async {
        await txn.rawQuery('DELETE FROM orderProductItems');
        await txn.rawQuery('DELETE FROM Products');
        await txn.rawQuery('DELETE FROM Categories');
        await txn.rawQuery('DELETE FROM Orders');
        await txn.rawQuery('DELETE FROM Clients');
      });
      print('Database content cleared');
    } catch (e) {
      print('Error clearing database: $e');
    }
  }

  // Restore database if needed
  Future<bool> restoreDatabaseIfNeeded(BuildContext context) async {
    bool restoreConfirmed = await _showRestoreConfirmationDialog(context);
    if (restoreConfirmed) {
      bool restoreSuccess = await restoreDatabase();
      if (restoreSuccess) {
        print('Database restored successfully');
        return true;
      } else {
        print('Failed to restore database');
        await createTables();
        return false;
      }
    } else {
      print('Restore canceled by user');
      return false;
    }
  }

  //Currency
  Future<void> insertInitialExchangeRates() async {
    try {
      var batch = db!.batch();

      batch.execute("""
         INSERT INTO exchangeRates (currency_from, currency_to, rate)
         VALUES 
           ('USD', 'EGP', 47.66),
           ('EUR', 'EGP', 51.13),
           ('EGP', 'USD', ${1 / 47.66}),
           ('USD', 'EUR', 0.85),
           ('EUR', 'USD', 1.18),
           ('EGP', 'EUR', ${1 / 51.13})
       """);

      await batch.commit();
      print('Initial exchange rates inserted successfully');
    } catch (e) {
      print('Error inserting initial exchange rates: $e');
    }
  }

  Future<double> getExchangeRate(String from, String to) async {
    try {
      final List<Map<String, dynamic>> result = await db!.query(
        'exchangeRates',
        where: 'currency_from = ? AND currency_to = ?',
        whereArgs: [from, to],
      );

      if (result.isNotEmpty) {
        return result.first['rate'] as double;
      } else {
        throw Exception('Exchange rate not found');
      }
    } catch (e) {
      print('Error fetching exchange rate: $e');
      return 0.0; // Handle error case
    }
  }
}
