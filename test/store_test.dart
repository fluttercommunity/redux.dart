import 'package:redux/redux.dart';
import 'package:test/test.dart';
import 'utils.dart';

main() {
  group('store', () {
    test('calls the reducer when an action is fired', () {
      var reducer = new StringReducer();
      var store = new Store(reducer, initialState: 'Hello');
      var action = 'test';
      store.dispatch(action);
      expect(store.state, equals(action));
    });

    test('when two reducers are combined, each reducer is invoked.', () {
      var combinedReducer =
          new CombinedReducer([new Reducer1(), new Reducer2()]);
      var store = new Store(combinedReducer, initialState: 'hello');
      expect(store.state, equals('hello'));
      store.dispatch('helloReducer1');
      expect(store.state, equals('reducer 1 reporting'));
      store.dispatch('helloReducer2');
      expect(store.state, equals('reducer 2 reporting'));
    });

    test('canceled subscriber should not be notified', () {
      bool subscriber1Called = false;
      bool subscriber2Called = false;

      var reducer = new StringReducer();
      var store = new Store(reducer, initialState: 'hello', syncStream: true);
      store.onChange.listen((String state) {
        subscriber1Called = true;
      });
      var subscription = store.onChange.listen((String state) {
        subscriber2Called = true;
      });
      subscription.cancel();
      store.dispatch("action");
      expect(subscriber1Called, isTrue);
      expect(subscriber2Called, isFalse);
    });

    test('store emits current state to subscribers', () {
      var reducer = new StringReducer();
      var action = 'test';
      var stateFromOnChangeListener = 'incorrectState';
      var store = new Store(reducer, initialState: 'hello', syncStream: true);
      store.onChange.listen((state) => stateFromOnChangeListener = state);
      store.dispatch(action);
      expect(stateFromOnChangeListener, equals(action));
    });
  });
}
