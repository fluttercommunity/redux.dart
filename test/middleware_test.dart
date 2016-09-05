import 'package:redux/redux.dart';
import 'package:test/test.dart';

void main() {
  test('actions should be run through the middleware', () {
    int counter = 0;

    Reducer<String, String> reducer = (state, action) {
      return state;
    };

    Middleware<String, String> middleware = (store, action, next) {
      counter += 1;
      next(action);
    };

    Store<String, String> store = new Store(reducer,
        initialState: 'Hello',
        middleware: <Middleware<String, String>>[middleware]);

    store.dispatch('test');

    expect(counter, equals(1));
  });

  test('actions should be run through the middleware in the correct order', () {
    int counter = 0;
    List<String> order = [];

    Reducer<String, String> reducer = (state, action) {
      return state;
    };

    Middleware<String, String> middleware1 = (store, action, next) {
      counter += 1;
      order.add('first');
      next(action);
      order.add('third');
    };

    Middleware<String, String> middleware2 = (store, action, next) {
      counter += 1;
      order.add('second');
      next(action);
    };

    Store<String, String> store = new Store(reducer,
        initialState: 'Hello', middleware: [middleware1, middleware2]);

    store.dispatch('test');

    expect(counter, equals(2));
    expect(order, equals(<String>['first', 'second', 'third']));
  });

  test('actions should be to dispatch through the chain multiple times', () {
    int counter = 0;
    List<String> order = [];

    Reducer<String, String> reducer = (state, action) {
      return state;
    };

    Middleware<String, String> middleware1 = (store, action, next) {
      counter += 1;
      order.add('first');
      next(action);
      order.add('third');
      next('another action');
    };

    Middleware<String, String> middleware2 = (store, action, next) {
      counter += 1;
      order.add('second');
      next(action);
    };

    Store<String, String> store = new Store(reducer,
        initialState: 'Hello', middleware: [middleware1, middleware2]);

    store.dispatch('test');

    expect(counter, equals(3));
    expect(order, equals(<String>['first', 'second', 'third', 'second']));
  });

  test('actions should be to be dispatch through the whole chain', () {
    int counter = 0;
    List<String> order = [];
    bool hasDispatched = false;

    Reducer<String, String> reducer = (state, action) {
      return state;
    };

    Middleware<String, String> middleware1 = (store, action, next) {
      counter += 1;
      order.add('first');
      next(action);
      order.add('third');
      if (!hasDispatched) {
        hasDispatched = true;

        store.dispatch('another action');
      }
    };

    Middleware<String, String> middleware2 = (store, action, next) {
      counter += 1;
      order.add('second');
      next(action);
    };

    Store<String, String> store = new Store(reducer,
        initialState: 'Hello', middleware: [middleware1, middleware2]);

    store.dispatch('test');

    expect(counter, equals(4));
    expect(
        order,
        equals(
            <String>['first', 'second', 'third', 'first', 'second', 'third']));
  });
}
