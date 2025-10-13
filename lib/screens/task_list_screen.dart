import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  String _filterStatus = 'todas';
  final _titleController = TextEditingController();
  String _selectedPriority = 'média';
  
  final Map<String, String> _priorityLabels = {
    'baixa': 'Baixa',
    'média': 'Média',
    'alta': 'Alta',
  };

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await DatabaseService.instance.readAll();
    setState(() {
      _tasks = tasks;
      _applyFilter();
    });
  }
  
  void _applyFilter() {
    setState(() {
      if (_filterStatus == 'completas') {
        _filteredTasks = _tasks.where((task) => task.completed).toList();
      } else if (_filterStatus == 'pendentes') {
        _filteredTasks = _tasks.where((task) => !task.completed).toList();
      } else {
        _filteredTasks = List.from(_tasks);
      }
    });
  }

  Future<void> _addTask() async {
    if (_titleController.text.trim().isEmpty) return;

    final task = Task(
      title: _titleController.text.trim(), 
      priority: _selectedPriority
    );
    await DatabaseService.instance.create(task);
    _titleController.clear();
    _loadTasks();
  }

  Future<void> _toggleTask(Task task) async {
    final updated = task.copyWith(completed: !task.completed);
    await DatabaseService.instance.update(updated);
    _loadTasks();
  }

  Future<void> _deleteTask(String id) async {
    await DatabaseService.instance.delete(id);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '${_filteredTasks.length} tarefas',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'Nova tarefa...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addTask,
                      child: const Text('Adicionar'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Prioridade: '),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _selectedPriority,
                      items: _priorityLabels.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPriority = newValue;
                          });
                        }
                      },
                    ),
                    const Spacer(),
                    const Text('Filtrar: '),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _filterStatus,
                      items: const [
                        DropdownMenuItem(
                          value: 'todas',
                          child: Text('Todas'),
                        ),
                        DropdownMenuItem(
                          value: 'completas',
                          child: Text('Completas'),
                        ),
                        DropdownMenuItem(
                          value: 'pendentes',
                          child: Text('Pendentes'),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _filterStatus = newValue;
                            _applyFilter();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                final task = _filteredTasks[index];
                return ListTile(
                  leading: Checkbox(
                    value: task.completed,
                    onChanged: (_) => _toggleTask(task),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text('Prioridade: ${_priorityLabels[task.priority] ?? task.priority}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteTask(task.id),
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