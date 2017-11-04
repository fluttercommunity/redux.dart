import 'package:redux/redux.dart';
import 'dart:async';

String reducer1(String state, action) {
  if (action == 'helloReducer1') return 'reducer 1 reporting';
  return state;
}

String reducer2(String state, action) {
  if (action == 'helloReducer2') return 'reducer 2 reporting';
  return state;
}

const notFound = 'not found';

String stringReducer(String state, action) =>
    action is String ? action : notFound;

class StringReducer extends ReducerClass<String> {
  @override
  String call(String state, action) => stringReducer(state, action);
}

class IncrementMiddleware extends MiddlewareClass<String> {
  int counter = 0;
  StreamController<String> _invocationsController =
      new StreamController.broadcast(sync: true);

  Stream<String> get invocations => _invocationsController.stream;

  call(Store<String> store, action, NextDispatcher next) {
    _invocationsController.add(action);
    counter += 1;
    next(action);
  }
}

class ExtraActionIncrementMiddleware extends IncrementMiddleware {
  call(Store<String> store, action, NextDispatcher next) {
    _invocationsController.add(action);
    counter += 1;
    next(action);
    next('another action');
  }
}

class ExtraActionIfDispatchedIncrementMiddleware extends IncrementMiddleware {
  bool hasDispatched = false;

  call(Store<String> store, action, NextDispatcher next) {
    _invocationsController.add(action);
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
