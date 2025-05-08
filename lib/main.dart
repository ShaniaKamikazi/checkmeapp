// Full Flutter Code for CheckMe Todo App

import 'package:flutter/material.dart';

void main() => runApp(CheckMeApp());

class CheckMeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userName: _emailController.text.split('@')[0]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CheckMe Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value != null && value.contains('@') ? null : 'Enter a valid email',
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value != null && value.length >= 6 ? null : 'Password must be 6+ chars',
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _login, child: Text('Login')),
            ],
          ),
        ),
      ),
    );
  }
}

// Todo Model
class Todo {
  String title;
  String description;
  bool isDone;
  DateTime? dueDate;
  String category;

  Todo({required this.title, this.description = '', this.isDone = false, this.dueDate, this.category = "General"});
}


class HomeScreen extends StatefulWidget {
  final String userName;
  HomeScreen({required this.userName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Todo> todos = [];
  String searchQuery = '';
  String filterCategory = 'All';

  void _addTodo() {
    String title = '';
    String description = '';
    DateTime? dueDate;
    String category = 'General';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Todo'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
              DropdownButton<String>(
                value: category,
                onChanged: (newValue) => setState(() => category = newValue!),
                items: ['General', 'School', 'Personal', 'Urgent']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
              ),
              ElevatedButton(
                onPressed: () async {
                  dueDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                },
                child: Text('Pick Due Date'),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (title.isNotEmpty) {
                setState(() {
                  todos.add(Todo(title: title, description: description, dueDate: dueDate, category: category));
                });
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          )
        ],
      ),
    );
  }

  List<Todo> get _filteredTodos {
    var list = todos.where((todo) => todo.title.contains(searchQuery) || todo.description.contains(searchQuery)).toList();
    if (filterCategory != 'All') {
      list = list.where((todo) => todo.category == filterCategory).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CheckMe Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showSearch(context: context, delegate: TodoSearch(todos: todos)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(child: Text(widget.userName[0].toUpperCase())),
                SizedBox(width: 10),
                Text('Welcome, ${widget.userName}!', style: TextStyle(fontSize: 20))
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            children: ['All', 'School', 'Personal', 'Urgent'].map((cat) => ChoiceChip(
              label: Text(cat),
              selected: filterCategory == cat,
              onSelected: (selected) => setState(() => filterCategory = cat),
            )).toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = _filteredTodos[index];
                return Dismissible(
                  key: Key(todo.title),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) => setState(() => todos.remove(todo)),
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.isDone,
                      onChanged: (value) => setState(() => todo.isDone = value!),
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (todo.dueDate != null && todo.dueDate!.isBefore(DateTime.now()))
                          Text('Overdue', style: TextStyle(color: Colors.red)),
                        if (todo.category.isNotEmpty)
                          Text('Category: ${todo.category}'),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TodoDetailScreen(todo: todo)),
                    ),
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

// Todo Details Screen
class TodoDetailScreen extends StatelessWidget {
  final Todo todo;
  TodoDetailScreen({required this.todo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${todo.title}', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text('Description: ${todo.description}'),
            if (todo.dueDate != null)
              Text('Due Date: ${todo.dueDate!.toLocal().toString().split(' ')[0]}'),
            Text('Category: ${todo.category}'),
          ],
        ),
      ),
    );
  }
}

// Search Delegate
class TodoSearch extends SearchDelegate {
  final List<Todo> todos;
  TodoSearch({required this.todos});

  @override
  List<Widget> buildActions(BuildContext context) => [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) => IconButton(icon: Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = todos.where((todo) => todo.title.contains(query)).toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(suggestions[index].title),
      ),
    );
  }
}