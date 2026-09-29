import 'package:flutter/material.dart';

import '../../domain/entities/todo_entity.dart';

class TodoListItem extends StatelessWidget {
  final TodoEntity todo;
  final VoidCallback onDelete;

  const TodoListItem({super.key, required this.todo, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(todo.title),
      subtitle: Text(todo.description),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}
