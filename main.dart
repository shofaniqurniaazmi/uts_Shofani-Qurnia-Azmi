import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FORM",
      home: GetDataTodos(),
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<List<Todo>> fetchTodos() async {
  final response = await http
      .get(Uri.parse('https://calm-plum-jaguar-tutu.cyclic.app/todos'));
  if (response.statusCode == 200) {
    List<dynamic> body = json.decode(response.body)['data'];
    List<Todo> todos = body.map((item) => Todo.fromJson(item)).toList();
    return todos;
  } else {
    throw Exception('Failed to load Todos');
  }
}

class Todo {
  final String id;
  final String todoName;
  final bool isComplete;

  Todo({required this.id, required this.todoName, required this.isComplete});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['_id'] ?? '',
      todoName: json['todoName'] ?? '',
      isComplete: json['isComplete'] ?? false,
    );
  }
}

class GetDataTodos extends StatefulWidget {
  @override
  _GetDataTodosState createState() => _GetDataTodosState();
}

class _GetDataTodosState extends State<GetDataTodos> {
  late Future<List<Todo>> todos;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    todos = fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Todos from API',
              textAlign: TextAlign.left,
            ),
            Spacer(),
            Icon(Icons.search),
          ],
        ),
        backgroundColor: Colors.grey,
      ),
      body: Center(
        child: FutureBuilder<List<Todo>>(
          future: todos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final filteredTodos = snapshot.data!.where((todo) {
                final search = searchController.text.toLowerCase();
                return todo.todoName.toLowerCase().contains(search);
              }).toList();

              return Column(
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      contentPadding: const EdgeInsets.all(10.0),
                    ),
                    onChanged: (text) {
                      setState(
                          () {}); // Memicu rebuild ketika isi pencarian berubah
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredTodos.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailPage(todo: filteredTodos[index]),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ID: ${filteredTodos[index].id}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'Name: ${filteredTodos[index].todoName}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'Is Complete: ${filteredTodos[index].isComplete}',
                                  style: TextStyle(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Todo todo;

  const DetailPage({Key? key, required this.todo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ID: ${todo.id}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Name: ${todo.todoName}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            Text(
              'Is Complete: ${todo.isComplete}',
            ),
          ],
        ),
      ),
    );
  }
}
