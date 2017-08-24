import 'package:redux/redux.dart';
import 'package:test/test.dart';
import 'utils.dart';

main() {
  group('store', () {
    test('calls the reducer when an action is fired', () {
      final store = new Store(stringReducer, initialState: 'Hello');
      final action = 'test';
      store.dispatch(action);
      expect(store.state, equals(action));
    });

    test('reducers can be a Class', () {
      expect(
        new StringReducer(),
        new isInstanceOf<Reducer<String>>(),
      );
    });

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

    test('canceled subscriber should not be notified', () {
      var subscriber1Called = false;
      var subscriber2Called = false;
      final store = new Store(
        stringReducer,
        initialState: 'hello',
        syncStream: true,
      );
      final subscription = store.onChange.listen((String state) {
        subscriber2Called = true;
      });

      store.onChange.listen((String state) {
        subscriber1Called = true;
      });

      subscription.cancel();
      store.dispatch("action");
      expect(subscriber1Called, isTrue);
      expect(subscriber2Called, isFalse);
    });

    test('store emits current state to subscribers', () {
      final action = 'test';
      var stateFromOnChangeListener = 'incorrectState';
      final store =
          new Store(stringReducer, initialState: 'hello', syncStream: true);
      store.onChange.listen((state) => stateFromOnChangeListener = state);
      store.dispatch(action);
      expect(stateFromOnChangeListener, equals(action));
    });
  });
}
