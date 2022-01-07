import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class TablePage extends StatefulWidget {
  final String tableName;
  final Database database;

  const TablePage({
    Key? key,
    required this.tableName,
    required this.database,
  }) : super(key: key);

  @override
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  final TextEditingController controller = TextEditingController();
  List<Map> items = [];
  late Future<void> itemsFuture;
  late final int total;
  late final int pages;
  int currentPage = 1;
  final int limit = 100;
  int offset = 0;

  @override
  void initState() {
    super.initState();

    itemsFuture = pageFuture();
  }

  Future<void> pageFuture() async {
    itemsFuture = getItems();

    final List<Map> result = await widget.database.rawQuery('''
      SELECT COUNT(*) as count FROM ${widget.tableName}
    ''');

    total = result[0]['count'] as int;
    pages = (total / 100).ceil();
  }

  Future<void> getItems() async {
    final String query =
        'SELECT * FROM ${widget.tableName} LIMIT $limit OFFSET $offset';

    items = await widget.database.rawQuery(query);

    controller.text = query;
  }

  void onPrev() {
    setState(() {
      currentPage--;
      offset -= limit;
      itemsFuture = getItems();
    });
  }

  void onNext() {
    setState(() {
      currentPage++;
      offset += limit;
      itemsFuture = getItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tableName),
      ),
      body: Column(
        children: [
          /*Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Run query'),
            ),
          ),*/
          Expanded(
            child: FutureBuilder(
              future: itemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                Widget child;

                if (items.isNotEmpty) {
                  final List<TableRow> rows = [];

                  // Headers
                  final List<Widget> headerChildren = [];

                  items[0].forEach((key, value) {
                    headerChildren.add(
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            key.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  });

                  rows.add(TableRow(children: headerChildren));

                  // Records
                  for (final Map item in items) {
                    final List<Widget> children = [];

                    item.forEach((key, value) {
                      children.add(
                        GestureDetector(
                          onLongPress: () {
                            Clipboard.setData(
                              ClipboardData(text: value.toString()),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text('Copied to clipboard!'),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              value.toString(),
                            ),
                          ),
                        ),
                      );
                    });

                    rows.add(TableRow(
                      children: children,
                    ));
                  }

                  child = SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: rows,
                    ),
                  );
                } else {
                  child = const Text("There's nothing to show.");
                }

                return Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  child: ListView(
                    children: [
                      const SizedBox(height: 20),
                      _Paginator(
                        onNext: onNext,
                        onPrev: onPrev,
                        total: pages,
                        current: currentPage,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text('Total records: $total'),
                      ),
                      child,
                      _Paginator(
                        onNext: onNext,
                        onPrev: onPrev,
                        total: pages,
                        current: currentPage,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Paginator extends StatelessWidget {
  final void Function() onNext;
  final void Function() onPrev;
  final int total;
  final int current;

  const _Paginator({
    Key? key,
    required this.onNext,
    required this.onPrev,
    required this.total,
    required this.current,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Opacity(
          opacity: current != 1 ? 1 : 0,
          child: IgnorePointer(
            ignoring: current == 1,
            child: ElevatedButton(
              onPressed: onPrev,
              child: const Icon(
                Icons.chevron_left,
              ),
            ),
          ),
        ),
        Text('$current of $total'),
        Opacity(
          opacity: total > current ? 1 : 0,
          child: IgnorePointer(
            ignoring: current == total,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Icon(
                Icons.chevron_right,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
