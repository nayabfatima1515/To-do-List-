import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Map<String, dynamic>> tasks = [];
  TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // Load tasks from SharedPreferences
  void loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString("tasks");
    if (data != null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  // Save tasks to SharedPreferences
  void saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("tasks", jsonEncode(tasks));
  }

  // Add new task
  void addTask() {
    if (taskController.text.isEmpty) return;

    setState(() {
      tasks.add({
        "title": taskController.text,
        "completed": false,
      });
    });

    taskController.clear();
    saveTasks();
  }

  // Delete task
  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks();
  }

  // Toggle completed
  void toggleTask(int index) {
    setState(() {
      tasks[index]["completed"] = !(tasks[index]["completed"] ?? false);
    });
    saveTasks();
  }

  // Edit task
  void editTask(int index) {
    TextEditingController editController =
        TextEditingController(text: tasks[index]["title"]);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Task"),
          content: TextField(controller: editController),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  tasks[index]["title"] = editController.text;
                });
                saveTasks();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Simple To-Do App"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input Section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: const InputDecoration(
                      hintText: "Enter task",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: addTask,
                  icon: const Icon(
                    Icons.add_circle,
                    color: Colors.teal,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Task List
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text("No tasks added yet"))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        var task = tasks[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(
                              task["title"] ?? "",
                              style: TextStyle(
                                decoration: (task["completed"] ?? false)
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            leading: IconButton(
                              icon: Icon(
                                Icons.check_circle,
                                color: (task["completed"] ?? false)
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              onPressed: () => toggleTask(index),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => editTask(index),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => deleteTask(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}