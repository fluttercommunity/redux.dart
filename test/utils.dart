import 'package:redux/redux.dart';
import 'dart:async';

class Reducer1 implements Reducer<String> {
  String reduce(String state, dynamic action) {
    if (action == 'helloReducer1') return 'reducer 1 reporting';
    return state;
  }
}

class Reducer2 implements Reducer<String> {
  String reduce(String state, dynamic action) {
    if (action == 'helloReducer2') return 'reducer 2 reporting';
    return state;
  }
}

class StringReducer implements Reducer<String> {
  String reduce(String state, dynamic action) {
    return action;
  }
}

class IncrementMiddleware implements Middleware<int> {
  int counter = 0;
  StreamController<String> _invocationsController =
      new StreamController.broadcast(sync: true);
  Stream<String> get invocations => _invocationsController.stream;
  call(Store<int> store, dynamic action, NextDispatcher next) {
    _invocationsController.add(action);
    counter += 1;
    next(action);
  }
}

class ExtraActionIncrementMiddleware extends IncrementMiddleware {
  call(Store<int> store, dynamic action, NextDispatcher next) {
    _invocationsController.add(action);
    counter += 1;
    next(action);
    next('another action');
  }
}

class ExtraActionIfDispatchedIncrementMiddleware extends IncrementMiddleware {
  bool hasDispatched = false;

  call(Store<int> store, dynamic action, NextDispatcher next) {
    _invocationsController.add(action);
    counter += 1;
    next(action);
    if (!hasDispatched) {
      hasDispatched = true;
      store.dispatch('another action');
    }
  }
}
