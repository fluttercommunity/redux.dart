import 'package:redux/redux.dart';
import 'dart:async';

String reducer1(String state, String action) {
  if (action == 'helloReducer1') return 'reducer 1 reporting';
  return state;
}

String reducer2(String state, String action) {
  if (action == 'helloReducer2') return 'reducer 2 reporting';
  return state;
}

const notFound = 'not found';

String stringReducer(String state, String action) =>
    action is String ? action : notFound;

String testActionReducer(String state, TestAction action) {
  switch(action.runtimeType) {
    case TestAction1:
      return "test action 1";
    case TestAction2:
      return "test action 2";
    case TestAction3:
      return "test action 3";
    default:
      return notFound;
  }
}

class StringReducer extends ReducerClass<String, String> {
  @override
  String call(String state, action) => stringReducer(state, action);
}

class IncrementMiddleware extends MiddlewareClass<String, String> {
  int counter = 0;
  StreamController<String> _invocationsController =
      new StreamController.broadcast(sync: true);

  Stream<String> get invocations => _invocationsController.stream;

  call(Store<String, String> store, String action, NextDispatcher next) {
    _invocationsController.add(action);
    counter += 1;
    next(action);
  }
}

class ExtraActionIncrementMiddleware extends IncrementMiddleware {
  call(Store<String, String> store, String action, NextDispatcher next) {
    _invocationsController.add(action);
    counter += 1;
    next(action);
    next('another action');
  }
}

class ExtraActionIfDispatchedIncrementMiddleware extends IncrementMiddleware {
  bool hasDispatched = false;

  call(Store<String, String> store, action, NextDispatcher next) {
    _invocationsController.add(action);
    counter += 1;
    next(action);
    if (!hasDispatched) {
      hasDispatched = true;
      store.dispatch('another action');
    }
  }
}

class TestAction {}

class TestAction1 extends TestAction {}

class TestAction2 extends TestAction {}

class TestAction3 extends TestAction {}

class UnsupportedTestAction extends TestAction {}
