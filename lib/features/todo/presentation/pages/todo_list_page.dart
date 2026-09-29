import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/todo_bloc.dart';
import '../widgets/add_todo_dialog.dart';
import '../widgets/todo_list_item.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading || state is TodoInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TodoError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        context.read<TodoBloc>().add(const LoadTodos()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is TodoLoaded) {
            if (state.todos.isEmpty) {
              return const Center(child: Text('No todos yet — add one.'));
            }
            return ListView.builder(
              itemCount: state.todos.length,
              itemBuilder: (context, index) {
                final todo = state.todos[index];
                return TodoListItem(
                  todo: todo,
                  onDelete: () =>
                      context.read<TodoBloc>().add(RemoveTodo(todo.id)),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AddTodoDialog(
            onSubmit: (title, description) => context
                .read<TodoBloc>()
                .add(AddTodo(title: title, description: description)),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
