import 'dart:async';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

import 'test_data.dart';

void main() {
  group('Middleware', () {
    test('are invoked by the store', () {
      final middleware = IncrementMiddleware();
      final store = Store<String>(
        stringReducer,
        initialState: 'hello',
        middleware: [middleware],
      );
      store.dispatch('test');
      expect(middleware.counter, equals(1));
    });

    test('are applied in the correct order', () {
      final middleware1 = IncrementMiddleware();
      final middleware2 = IncrementMiddleware();
      final store = Store<String>(
        stringReducer,
        initialState: 'hello',
        middleware: [middleware1, middleware2],
      );

      final order = <String>[];
      middleware1.invocations.listen((action) => order.add('first'));
      middleware2.invocations.listen((action) => order.add('second'));

      store.dispatch('test');
      expect(order[0], equals('first'));
      expect(order[1], equals('second'));
    });

    test('actions can be dispatched multiple times', () {
      final middleware1 = ExtraActionIncrementMiddleware();
      final middleware2 = IncrementMiddleware();
      final store = Store<String>(
        stringReducer,
        initialState: 'hello',
        middleware: [middleware1, middleware2],
      );

      final order = <String>[];
      middleware1.invocations.listen((action) => order.add('first'));
      middleware2.invocations.listen((action) => order.add('second'));

      store.dispatch('test');
      expect(order[0], equals('first'));
      expect(order[1], equals('second'));
      expect(order[2], equals('second'));
    });

    test('actions can be dispatched through entire chain', () {
      final middleware1 = ExtraActionIfDispatchedIncrementMiddleware();
      final middleware2 = IncrementMiddleware();
      final store = Store<String>(
        stringReducer,
        initialState: 'hello',
        middleware: [middleware1, middleware2],
      );

      final order = <String>[];
      middleware1.invocations.listen((action) => order.add('first'));
      middleware2.invocations.listen((action) => order.add('second'));

      store.dispatch('test');

      expect(order[0], equals('first'));
      expect(order[1], equals('second'));
      expect(order[2], equals('first'));
      expect(order[3], equals('second'));

      expect(middleware1.counter, equals(2));
    });

    test('dispatch returns the value from middleware', () async {
      final passthrough = PassThroughMiddleware<String>();
      final thunk = ThunkMiddleware<String>();
      Future<void> thunkAction(Store<String> store) async {
        await Future<void>.delayed(Duration(milliseconds: 5));
        store.dispatch("changed");
      }

      final store = Store<String>(
        stringReducer,
        initialState: 'hello',
        middleware: [passthrough, thunk],
      );

      final awaitableAction = store.dispatch(thunkAction) as Future<void>;

      // Did not change yet
      expect(store.state, equals('hello'));
      await awaitableAction;
      // The effect has taken place
      expect(store.state, equals('changed'));
    });
  });
}
