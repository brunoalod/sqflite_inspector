import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_inspector/sqflite_inspector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final String dbPath = await getDatabasesPath();
  final String path = join(dbPath, 'test.db');

  try {
    await deleteDatabase(path);
  } catch (e) {
    // Couldn't delete database.
  }

  await openDatabase(
    path,
    version: 2,
    onCreate: (db, version) async {
      await db.execute(
        '''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY, 
          first_name TEXT, 
          last_name TEXT,
          nickname TEXT,
          email TEXT,
          country TEXT,
          state TEXT,
          age INTEGER
        )''',
      );

      final Random random = Random();

      for (var i = 0; i < 500; i++) {
        await db.insert('users', {
          'first_name': 'FirstName$i',
          'last_name': 'LastName$i',
          'nickname': 'Nickname$i',
          'email': 'Email$i',
          'country': 'Country$i',
          'state': 'State$i',
          'age': random.nextInt(99),
        });
      }
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sqflite Inspector Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Sqflite Inspector Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return const SqfliteInspector();
              },
            ));
          },
          child: const Text(
            'Open Sqflite Inspector',
          ),
        ),
      ),
    );
  }
}
