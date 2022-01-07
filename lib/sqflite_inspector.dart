library sqflite_inspector;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_inspector/tables_list_page.dart';

class SqfliteInspector extends StatefulWidget {
  const SqfliteInspector({
    Key? key,
  }) : super(key: key);

  @override
  _SqfliteInspectorState createState() => _SqfliteInspectorState();
}

class _SqfliteInspectorState extends State<SqfliteInspector> {
  final List<FileSystemEntity> databases = [];
  late final Future<void> pageFuture;

  @override
  void initState() {
    super.initState();
    pageFuture = fetchDatabases();
  }

  Future<void> fetchDatabases() async {
    String path = await getDatabasesPath();

    final Directory dir = Directory(path.toString());
    final List<FileSystemEntity> dirDatabases = dir.listSync();

    databases.addAll(dirDatabases);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Databases'),
      ),
      body: FutureBuilder(
        future: pageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: databases.length,
            itemBuilder: (context, index) {
              final FileSystemEntity database = databases[index];

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return TablesListPage(databasePath: database.path);
                      },
                    ),
                  );
                },
                title: Text(basename(database.path.toString())),
                trailing: const Icon(Icons.chevron_right),
              );
            },
          );
        },
      ),
    );
  }
}
