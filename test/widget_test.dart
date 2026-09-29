import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_clean_architecture_template/features/todo/domain/entities/todo_entity.dart';
import 'package:flutter_clean_architecture_template/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:flutter_clean_architecture_template/features/todo/presentation/pages/todo_list_page.dart';

class MockTodoBloc extends MockBloc<TodoEvent, TodoState>
    implements TodoBloc {}

/// Widget tests for the presentation layer. The BLoC is mocked, so the page
/// is tested purely as a function of state — no use cases, repositories, or
/// network involved. That isolation is the payoff of the layered design.
void main() {
  late MockTodoBloc bloc;

  setUp(() {
    bloc = MockTodoBloc();
  });

  Widget buildPage() => MaterialApp(
        home: BlocProvider<TodoBloc>.value(
          value: bloc,
          child: const TodoListPage(),
        ),
      );

  final tTodo = TodoEntity(
    id: '1',
    title: 'Buy milk',
    description: 'From the store',
    isCompleted: false,
    createdAt: DateTime(2026, 1, 1),
  );

  testWidgets('shows a spinner while loading', (tester) async {
    when(() => bloc.state).thenReturn(TodoLoading());

    await tester.pumpWidget(buildPage());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the todos when loaded', (tester) async {
    when(() => bloc.state).thenReturn(TodoLoaded([tTodo]));

    await tester.pumpWidget(buildPage());

    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.text('From the store'), findsOneWidget);
  });

  testWidgets('shows an empty message when there are no todos',
      (tester) async {
    when(() => bloc.state).thenReturn(const TodoLoaded([]));

    await tester.pumpWidget(buildPage());

    expect(find.text('No todos yet — add one.'), findsOneWidget);
  });

  testWidgets('shows the error message on failure', (tester) async {
    when(() => bloc.state).thenReturn(const TodoError('Down'));

    await tester.pumpWidget(buildPage());

    expect(find.text('Down'), findsOneWidget);
  });

  testWidgets('tapping Retry on the error view reloads the todos',
      (tester) async {
    when(() => bloc.state).thenReturn(const TodoError('Down'));

    await tester.pumpWidget(buildPage());
    await tester.tap(find.text('Retry'));

    verify(() => bloc.add(const LoadTodos())).called(1);
  });

  testWidgets('tapping delete dispatches RemoveTodo', (tester) async {
    when(() => bloc.state).thenReturn(TodoLoaded([tTodo]));

    await tester.pumpWidget(buildPage());
    await tester.tap(find.byIcon(Icons.delete_outline));

    verify(() => bloc.add(const RemoveTodo('1'))).called(1);
  });
}
