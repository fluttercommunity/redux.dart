import 'package:redux/redux.dart';
import 'package:test/test.dart';

import 'test_data.dart';

void main() {
  group('Store', () {
    test('calls the reducer when an action is fired', () {
      final store = new Store<String>(stringReducer, initialState: 'Hello');
      final action = 'test';
      store.dispatch(action);
      expect(store.state, equals(action));
    });

    test('canceled subscriber should not be notified', () {
      var subscriber1Called = false;
      var subscriber2Called = false;
      final store = new Store<String>(
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
      store.dispatch('action');
      expect(subscriber1Called, isTrue);
      expect(subscriber2Called, isFalse);
    });

    test('store emits current state to subscribers', () {
      final action = 'test';
      final states = <String>[];
      final store = new Store<String>(
        stringReducer,
        initialState: 'hello',
        syncStream: true,
      );
      store.onChange.listen((state) => states.add(state));

      // Dispatch two actions. Both should be emitted by default.
      store.dispatch(action);
      store.dispatch(action);

      expect(states, <String>[action, action]);
    });

    test('store does not emit an onChange if distinct', () {
      final action = 'test';
      final states = <String>[];
      final store = new Store<String>(stringReducer,
          initialState: 'hello', syncStream: true, distinct: true);
      store.onChange.listen((state) => states.add(state));

      // Dispatch two actions. Only one should be emitted b/c distinct is true
      store.dispatch(action);
      store.dispatch(action);

      expect(states, <String>[action]);
    });
  });
}
