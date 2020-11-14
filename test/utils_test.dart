import 'package:redux/redux.dart';
import 'package:test/test.dart';

import 'test_data.dart';

String testAction1Reducer(String state, TestAction1 action) =>
    action.toString();

String testAction2Reducer(String state, TestAction2 action) =>
    action.toString();

void main() {
  group('Typed Reducers', () {
    test('can be used standalone', () {
      final store = Store<String>(
        const TypedReducer<String, TestAction1>(testAction1Reducer),
        initialState: 'hello',
      );

      store.dispatch(TestAction1());
      expect(store.state, contains('TestAction1'));
    });

    test('are not invoked if they do not handle the action type', () {
      final initialState = 'hello';
      final store = Store<String>(
        const TypedReducer<String, TestAction1>(testAction1Reducer),
        initialState: initialState,
      );

      store.dispatch(TestAction3());

      // Since TestAction3 does not match any ReducerBindings, the state
      // should not be changed after dispatching TestAction3.
      expect(store.state, initialState);
    });
  });

  group('combineReducers', () {
    test('should invoke each reducer', () {
      final combinedReducer = combineReducers([
        reducer1,
        reducer2,
      ]);

      final store = Store(combinedReducer, initialState: 'hello');
      expect(store.state, equals('hello'));
      store.dispatch('helloReducer1');
      expect(store.state, equals('reducer 1 reporting'));
      store.dispatch('helloReducer2');
      expect(store.state, equals('reducer 2 reporting'));
    });

    test('works with TypedReducers', () {
      final store = Store<String>(
        combineReducers([
          TypedReducer<String, TestAction1>(testAction1Reducer),
          TypedReducer<String, TestAction2>(testAction2Reducer),
        ]),
        initialState: 'hello',
      );

      store.dispatch(TestAction1());
      expect(store.state, contains('TestAction1'));

      store.dispatch(TestAction2());
      expect(store.state, contains('TestAction2'));
    });

    test('can combine typed with non-typed reducers', () {
      final store = Store<String>(
        combineReducers([
          reducer1,
          TypedReducer<String, TestAction2>(testAction2Reducer),
        ]),
        initialState: 'hello',
      );

      store.dispatch('helloReducer1');
      expect(store.state, equals('reducer 1 reporting'));

      store.dispatch(TestAction2());
      expect(store.state, contains('TestAction2'));
    });
  });

  group('CombinedReducer', () {
    test('should invoke each reducer', () {
      const combinedReducer = CombinedReducer([
        UntypedReducer(reducer1),
        UntypedReducer(reducer2),
      ]);

      final store = Store(combinedReducer, initialState: 'hello');
      expect(store.state, equals('hello'));
      store.dispatch('helloReducer1');
      expect(store.state, equals('reducer 1 reporting'));
      store.dispatch('helloReducer2');
      expect(store.state, equals('reducer 2 reporting'));
    });

    test('works with TypedReducers', () {
      const combinedReducer = CombinedReducer<String>([
        TypedReducer<String, TestAction1>(testAction1Reducer),
        TypedReducer<String, TestAction2>(testAction2Reducer),
      ]);
      final store = Store<String>(
        combinedReducer,
        initialState: 'hello',
      );

      store.dispatch(TestAction1());
      expect(store.state, contains('TestAction1'));

      store.dispatch(TestAction2());
      expect(store.state, contains('TestAction2'));
    });

    test('can combine typed with non-typed reducers', () {
      final store = Store<String>(
        const CombinedReducer([
          UntypedReducer(reducer1),
          TypedReducer<String, TestAction2>(testAction2Reducer),
        ]),
        initialState: 'hello',
      );

      store.dispatch('helloReducer1');
      expect(store.state, equals('reducer 1 reporting'));

      store.dispatch(TestAction2());
      expect(store.state, contains('TestAction2'));
    });
  });

  group('Typed Middleware', () {
    void testAction1Middleware(
      Store<String> store,
      TestAction1 action,
      NextDispatcher next,
    ) {
      next('testAction1Middleware called');
    }

    void testAction2Middleware(
      Store<String> store,
      TestAction2 action,
      NextDispatcher next,
    ) {
      next('testAction2Middleware called');
    }

    test('are invoked based on the type of action they accept', () {
      final store = Store<String>(
        stringReducer,
        initialState: 'hello',
        middleware: [
          TypedMiddleware<String, TestAction1>(testAction1Middleware),
          TypedMiddleware<String, TestAction2>(testAction2Middleware),
        ],
      );

      store.dispatch(TestAction1());
      expect(store.state, 'testAction1Middleware called');

      store.dispatch(TestAction2());
      expect(store.state, 'testAction2Middleware called');
    });

    test(
        'are not invoked if they do not handle the Action and call the next piece of middleware in the chain',
        () {
      final initialState = 'hello';
      final store = Store<String>(
        stringReducer,
        initialState: initialState,
        middleware: [
          TypedMiddleware<String, TestAction1>(testAction1Middleware),
        ],
      );

      expect(store.state, initialState);

      store.dispatch(TestAction2());

      expect(store.state, notFound);
    });

    test('works with a function that has a dynamic action', () {
      final initialState = 'hello';
      final incrementMiddleware = IncrementMiddleware();
      final store = Store<String>(
        stringReducer,
        initialState: initialState,
        middleware: [
          TypedMiddleware<String, TestAction1>(incrementMiddleware),
          TypedMiddleware<String, TestAction2>(incrementMiddleware),
        ],
      );

      store.dispatch(TestAction1());
      store.dispatch(TestAction2());

      expect(incrementMiddleware.counter, 2);
    });
  });
}
