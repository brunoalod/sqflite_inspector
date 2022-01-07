import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_inspector/table_page.dart';

class TablesListPage extends StatefulWidget {
  final String databasePath;

  const TablesListPage({
    Key? key,
    required this.databasePath,
  }) : super(key: key);

  @override
  _TablesListPageState createState() => _TablesListPageState();
}

class _TablesListPageState extends State<TablesListPage> {
  final List<String> tables = [];
  late final Future<void> pageFuture;
  late final Database db;

  @override
  void initState() {
    super.initState();
    pageFuture = getPageFuture();
  }

  Future<void> getPageFuture() async {
    db = await openDatabase(widget.databasePath);

    final List<Map> tables = await db.rawQuery(
      'SELECT name FROM sqlite_master WHERE type = "table" and name != "sqlite_sequence"',
    );

    for (final Map table in tables) {
      this.tables.add(table['name']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tables'),
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
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final String table = tables[index];

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return TablePage(
                          tableName: table,
                          database: db,
                        );
                      },
                    ),
                  );
                },
                title: Text(table),
                trailing: const Icon(Icons.chevron_right),
              );
            },
          );
        },
      ),
    );
  }
}
