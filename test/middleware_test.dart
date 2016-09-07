import 'package:redux/redux.dart';
import 'package:test/test.dart';
import 'utils.dart';

main() {
  group('middleware', () {
    test('are invoked by the store', () {
      var reducer = new StringReducer();
      var middleware = new IncrementMiddleware();
      var store =
          new Store(reducer, initialState: 'hello', middleware: [middleware]);
      store.dispatch('test');
      expect(middleware.counter, equals(1));
    });

    test('are applied in the correct order', () {
      var reducer = new StringReducer();
      var middleware1 = new IncrementMiddleware();
      var middleware2 = new IncrementMiddleware();
      var middleware = [middleware1, middleware2];
      var store =
          new Store(reducer, initialState: 'hello', middleware: middleware);

      var order = [];
      middleware1.invocations.listen((action) => order.add('first'));
      middleware2.invocations.listen((action) => order.add('second'));

      store.dispatch('test');
      expect(order[0], equals('first'));
      expect(order[1], equals('second'));
    });

    test('actions can be dispatched multiple times', () {
      var reducer = new StringReducer();
      var middleware1 = new ExtraActionIncrementMiddleware();
      var middleware2 = new IncrementMiddleware();
      var middleware = [middleware1, middleware2];
      var store =
          new Store(reducer, initialState: 'hello', middleware: middleware);

      var order = [];
      middleware1.invocations.listen((action) => order.add('first'));
      middleware2.invocations.listen((action) => order.add('second'));

      store.dispatch('test');
      expect(order[0], equals('first'));
      expect(order[1], equals('second'));
      expect(order[2], equals('second'));
    });

    test('actions can be dispatched through entire chain', () {
      var reducer = new StringReducer();
      var middleware1 = new ExtraActionIfDispatchedIncrementMiddleware();
      var middleware2 = new IncrementMiddleware();
      var middleware = [middleware1, middleware2];
      var store =
          new Store(reducer, initialState: 'hello', middleware: middleware);

      var order = [];
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
