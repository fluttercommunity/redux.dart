import 'package:redux/redux.dart';
import 'package:test/test.dart';
import 'test_data.dart';

main() {
  group('Combining Reducers', () {
    final testAction1Reducer = (String state, TestAction1 action) {
      return action.toString();
    };

    final testAction2Reducer = (String state, TestAction2 action) {
      return action.toString();
    };

    group('Type Safe Combinations', () {
      test('are invoked when they match the Type of the dispatched action', () {
        final store = new Store<String>(
          combineTypedReducers([
            new ReducerBinding<String, TestAction1>(testAction1Reducer),
            new ReducerBinding<String, TestAction2>(testAction2Reducer),
          ]),
          initialState: 'hello',
        );

        store.dispatch(new TestAction1());
        expect(store.state, contains("TestAction1"));

        store.dispatch(new TestAction2());
        expect(store.state, contains("TestAction2"));
      });

      test('are not invoked if they do not handle the action type', () {
        final initialState = 'hello';
        final store = new Store<String>(
          combineTypedReducers([
            new ReducerBinding<String, TestAction1>(testAction1Reducer),
            new ReducerBinding<String, TestAction2>(testAction2Reducer),
          ]),
          initialState: initialState,
        );

        store.dispatch(new TestAction3());

        // Since TestAction3 does not match any ReducerBindings, the state
        // should not be changed after dispatching TestAction3.
        expect(store.state, initialState);
      });
    });

    group('Dynamic Combinations', () {
      test('when two reducers are combined, each reducer is invoked.', () {
        final combinedReducer = combineReducers<String>([
          reducer1,
          reducer2,
        ]);

        final store = new Store(combinedReducer, initialState: 'hello');
        expect(store.state, equals('hello'));
        store.dispatch('helloReducer1');
        expect(store.state, equals('reducer 1 reporting'));
        store.dispatch('helloReducer2');
        expect(store.state, equals('reducer 2 reporting'));
      });
    });
  });

  group('Typed Middleware', () {
    final testAction1Middleware = (
      Store<String> store,
      TestAction1 action,
      NextDispatcher next,
    ) {
      next("testAction1Middleware called");
    };

    final testAction2Middleware = (
      Store<String> store,
      TestAction2 action,
      NextDispatcher next,
    ) {
      next("testAction2Middleware called");
    };

    test('are invoked based on the type of action they accept', () {
      final store = new Store<String>(
        stringReducer,
        initialState: 'hello',
        middleware: combineTypedMiddleware([
          new MiddlewareBinding<String, TestAction1>(testAction1Middleware),
          new MiddlewareBinding<String, TestAction2>(testAction2Middleware),
        ]),
      );

      store.dispatch(new TestAction1());
      expect(store.state, "testAction1Middleware called");

      store.dispatch(new TestAction2());
      expect(store.state, "testAction2Middleware called");
    });

    test(
        'are not invoked if they do not handle the Action and call the next piece of middleware in the chain',
        () {
      final initialState = 'hello';
      final store = new Store<String>(
        stringReducer,
        initialState: initialState,
        middleware: combineTypedMiddleware([
          new MiddlewareBinding<String, TestAction1>(testAction1Middleware),
        ]),
      );

      expect(store.state, initialState);

      store.dispatch(new TestAction2());

      expect(store.state, notFound);
    });
  });
}
