import 'dart:async';

import 'package:redux/redux.dart';

String reducer1(String state, dynamic action) {
  if (action == 'helloReducer1') {
    return 'reducer 1 reporting';
  }
  return state;
}

String reducer2(String state, dynamic action) {
  if (action == 'helloReducer2') {
    return 'reducer 2 reporting';
  }
  return state;
}

const String notFound = 'not found';

String stringReducer(String state, dynamic action) =>
    action is String ? action : notFound;

class StringReducer extends ReducerClass<String> {
  @override
  String call(String state, dynamic action) => stringReducer(state, action);
}

class IncrementMiddleware extends MiddlewareClass<String> {
  int counter = 0;
  final _invocationsController =
      new StreamController<String>.broadcast(sync: true);

  Stream<String> get invocations => _invocationsController.stream;

  @override
  void call(Store<String> store, dynamic action, NextDispatcher next) {
    add(action);
    counter += 1;
    next(action);
  }

  void add(dynamic action) {
    if (action is String) {
      _invocationsController.add(action);
    }
  }
}

class ExtraActionIncrementMiddleware extends IncrementMiddleware {
  @override
  void call(Store<String> store, dynamic action, NextDispatcher next) {
    add(action);
    counter += 1;
    next(action);
    next('another action');
  }
}

class ExtraActionIfDispatchedIncrementMiddleware extends IncrementMiddleware {
  bool hasDispatched = false;

  @override
  void call(Store<String> store, dynamic action, NextDispatcher next) {
    add(action);
    counter += 1;
    next(action);
    if (!hasDispatched) {
      hasDispatched = true;
      store.dispatch('another action');
    }
  }
}

class TestAction1 {}

class TestAction2 {}

class TestAction3 {}
