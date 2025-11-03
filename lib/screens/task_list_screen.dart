import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../services/database_service.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  String _filter = 'all'; // all, completed, pending
  String? _categoryFilter; // null = todas, categoryId = específica
  String _sortBy = 'created'; // created, dueDate
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    List<Task> tasks;
    
    if (_sortBy == 'dueDate') {
      tasks = await DatabaseService.instance.readAllSortedByDueDate();
    } else {
      tasks = await DatabaseService.instance.readAll();
    }
    
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  List<Task> get _filteredTasks {
    List<Task> filtered = _tasks;

    // Filtro por status
    switch (_filter) {
      case 'completed':
        filtered = filtered.where((t) => t.completed).toList();
        break;
      case 'pending':
        filtered = filtered.where((t) => !t.completed).toList();
        break;
    }

    // Filtro por categoria
    if (_categoryFilter != null) {
      filtered = filtered.where((t) => t.categoryId == _categoryFilter).toList();
    }

    return filtered;
  }

  Future<void> _toggleTask(Task task) async {
    final updated = task.copyWith(completed: !task.completed);
    await DatabaseService.instance.update(updated);
    await _loadTasks();
  }

  Future<void> _deleteTask(Task task) async {
    // Confirmar exclusão
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService.instance.delete(task.id);
      await _loadTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarefa excluída'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _openTaskForm([Task? task]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: task),
      ),
    );

    if (result == true) {
      await _loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filteredTasks;
    final stats = _calculateStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Ordenação
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar por',
            onSelected: (value) {
              setState(() => _sortBy = value);
              _loadTasks();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'created',
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: _sortBy == 'created' ? Colors.blue : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Data de Criação',
                      style: TextStyle(
                        fontWeight: _sortBy == 'created' ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'dueDate',
                child: Row(
                  children: [
                    Icon(
                      Icons.event,
                      color: _sortBy == 'dueDate' ? Colors.blue : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Data de Vencimento',
                      style: TextStyle(
                        fontWeight: _sortBy == 'dueDate' ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Filtro por Status
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar por status',
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.list),
                    SizedBox(width: 8),
                    Text('Todas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Row(
                  children: [
                    Icon(Icons.pending_actions),
                    SizedBox(width: 8),
                    Text('Pendentes'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Row(
                  children: [
                    Icon(Icons.check_circle),
                    SizedBox(width: 8),
                    Text('Concluídas'),
                  ],
                ),
              ),
            ],
          ),

          // Filtro por Categoria
          PopupMenuButton<String?>(
            icon: const Icon(Icons.category),
            tooltip: 'Filtrar por categoria',
            onSelected: (value) => setState(() => _categoryFilter = value),
            itemBuilder: (context) => [
              PopupMenuItem<String?>(
                value: null,
                child: Row(
                  children: [
                    Icon(
                      Icons.clear_all,
                      color: _categoryFilter == null ? Colors.blue : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Todas as Categorias',
                      style: TextStyle(
                        fontWeight: _categoryFilter == null ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
              ...Categories.all.map((category) {
                return PopupMenuItem<String?>(
                  value: category.id,
                  child: Row(
                    children: [
                      Icon(
                        category.icon,
                        color: _categoryFilter == category.id 
                            ? category.color 
                            : category.color.withOpacity(0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontWeight: _categoryFilter == category.id ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          // Card de Estatísticas
          if (_tasks.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    Icons.list,
                    'Total',
                    stats['total'].toString(),
                  ),
                  _buildStatItem(
                    Icons.pending_actions,
                    'Pendentes',
                    stats['pending'].toString(),
                  ),
                  _buildStatItem(
                    Icons.check_circle,
                    'Concluídas',
                    stats['completed'].toString(),
                  ),
                ],
              ),
            ),

          // Alerta de Tarefas Vencidas
          if (_tasks.where((t) => t.isOverdue).isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_tasks.where((t) => t.isOverdue).length} tarefa(s) vencida(s)!',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (_tasks.where((t) => t.isOverdue).isNotEmpty)
            const SizedBox(height: 16),

          // Lista de Tarefas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTasks.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadTasks,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            return TaskCard(
                              task: task,
                              onTap: () => _openTaskForm(task),
                              onToggle: () => _toggleTask(task),
                              onDelete: () => _deleteTask(task),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nova Tarefa'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_filter) {
      case 'completed':
        message = 'Nenhuma tarefa concluída ainda';
        icon = Icons.check_circle_outline;
        break;
      case 'pending':
        message = 'Nenhuma tarefa pendente';
        icon = Icons.pending_actions;
        break;
      default:
        message = 'Nenhuma tarefa cadastrada';
        icon = Icons.task_alt;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _openTaskForm(),
            icon: const Icon(Icons.add),
            label: const Text('Criar primeira tarefa'),
          ),
        ],
      ),
    );
  }

  Map<String, int> _calculateStats() {
    return {
      'total': _tasks.length,
      'completed': _tasks.where((t) => t.completed).length,
      'pending': _tasks.where((t) => !t.completed).length,
    };
  }
}