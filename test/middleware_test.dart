import 'package:redux/redux.dart';
import 'package:test/test.dart';
import 'utils.dart';

main() {
  group('middleware', () {
    test('can be defined as a Class', () {
      expect(
        new IncrementMiddleware(),
        new isInstanceOf<Middleware<String>>(),
      );
    });

    test('are invoked by the store', () {
      final middleware = new IncrementMiddleware();
      final store = new Store(
        stringReducer,
        initialState: 'hello',
        middleware: [middleware],
      );
      store.dispatch('test');
      expect(middleware.counter, equals(1));
    });

    test('are applied in the correct order', () {
      final middleware1 = new IncrementMiddleware();
      final middleware2 = new IncrementMiddleware();
      final middleware = [middleware1, middleware2];
      final store = new Store(
        stringReducer,
        initialState: 'hello',
        middleware: middleware,
      );

      final order = [];
      middleware1.invocations.listen((action) => order.add('first'));
      middleware2.invocations.listen((action) => order.add('second'));

      store.dispatch('test');
      expect(order[0], equals('first'));
      expect(order[1], equals('second'));
    });

    test('actions can be dispatched multiple times', () {
      final middleware1 = new ExtraActionIncrementMiddleware();
      final middleware2 = new IncrementMiddleware();
      final middleware = [middleware1, middleware2];
      final store = new Store(
        stringReducer,
        initialState: 'hello',
        middleware: middleware,
      );

      final order = [];
      middleware1.invocations.listen((action) => order.add('first'));
      middleware2.invocations.listen((action) => order.add('second'));

      store.dispatch('test');
      expect(order[0], equals('first'));
      expect(order[1], equals('second'));
      expect(order[2], equals('second'));
    });

    test('actions can be dispatched through entire chain', () {
      final middleware1 = new ExtraActionIfDispatchedIncrementMiddleware();
      final middleware2 = new IncrementMiddleware();
      final middleware = [middleware1, middleware2];
      final store = new Store(
        stringReducer,
        initialState: 'hello',
        middleware: middleware,
      );

      final order = [];
      middleware1.invocations.listen((action) => order.add('first'));
      middleware2.invocations.listen((action) => order.add('second'));

      store.dispatch('test');

      expect(order[0], equals('first'));
      expect(order[1], equals('second'));
      expect(order[2], equals('first'));
      expect(order[3], equals('second'));

      expect(middleware1.counter, equals(2));
    });

    test('actions can be dispatched through entire chain', () {
      final middleware1 = new ExtraActionIfDispatchedIncrementMiddleware();
      final middleware2 = new IncrementMiddleware();
      final middleware = [middleware1, middleware2];
      final store = new Store(
        stringReducer,
        initialState: 'hello',
        middleware: middleware,
      );

      final order = [];
      middleware1.invocations.listen((action) => order.add('first'));
      middleware2.invocations.listen((action) => order.add('second'));

      store.dispatch('test');

      expect(order[0], equals('first'));
      expect(order[1], equals('second'));
      expect(order[2], equals('first'));
      expect(order[3], equals('second'));

      expect(middleware1.counter, equals(2));
    });
  });
}
