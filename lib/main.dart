import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Task {
  String title;
  String description;
  bool isCompleted;

  Task(this.title, this.description, this.isCompleted);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tareas',
      theme: ThemeData(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal,
        ),
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Task> tasks = [];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEditing = false;
  int editingIndex = -1;

  List<Task> get pendingTasks {
    return tasks.where((task) => !task.isCompleted).toList();
  }

  List<Task> get completedTasks {
    return tasks.where((task) => task.isCompleted).toList();
  }

  void addTask() {
    setState(() {
      tasks.add(Task(titleController.text, descriptionController.text, false));
      titleController.clear();
      descriptionController.clear();
    });
  }

  void editTask(int index) {
    setState(() {
      tasks[index].title = titleController.text;
      tasks[index].description = descriptionController.text;
      isEditing = false;
      titleController.clear();
      descriptionController.clear();
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void toggleTask(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
    });
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Tarea' : 'Agregar Tarea'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Descripción'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (isEditing) {
                  editTask(editingIndex);
                } else {
                  addTask();
                }
                Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Editar' : 'Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Seguro que quieres eliminar esta tarea?'),
              SizedBox(height: 10),
              Text('Título: ${tasks[index].title}'),
              Text('Descripción: ${tasks[index].description}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                deleteTask(index);
                Navigator.of(context).pop();
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Tres pestañas: Todas, Pendientes y Completadas
      child: Scaffold(
        appBar: AppBar(
          title: Text('Lista de Tareas'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Todas'),
              Tab(text: 'Pendientes'),
              Tab(text: 'Completadas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTaskList(tasks),
            _buildTaskList(pendingTasks),
            _buildTaskList(completedTasks),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              isEditing = false;
            });
            _showEditDialog(context);
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> taskList) {
    return ListView.builder(
      itemCount: taskList.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(
              taskList[index].title,
              style: TextStyle(
                decoration: taskList[index].isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: Text(taskList[index].description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      isEditing = true;
                      editingIndex = tasks.indexOf(taskList[index]);
                      titleController.text = taskList[index].title;
                      descriptionController.text = taskList[index].description;
                    });
                    _showEditDialog(context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteConfirmationDialog(
                        context, tasks.indexOf(taskList[index]));
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    toggleTask(tasks.indexOf(taskList[index]));
                  },
                  style: ElevatedButton.styleFrom(
                    primary:
                        taskList[index].isCompleted ? Colors.green : Colors.red,
                  ),
                  child: Text(
                    taskList[index].isCompleted ? 'Completado' : 'Pendiente',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
