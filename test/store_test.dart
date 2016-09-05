import 'dart:async';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

void main() {
  test(
      '''
      when an action is fired, the corresponding reducer
      should be called and update the state of the application
      ''', () {
    Reducer<String, String> reducer = (state, action) {
      return action;
    };

    Store<String, String> store = new Store(reducer, initialState: 'Hello');

    var action = 'test';
    store.dispatch(action);

    expect(store.state, equals(action));
  });

  test(
      '''
      when two reducers are combined, and a series of actions are
      fired, every reducer should be invoked
      ''', () {
    String intialState = 'Hello';
    String helloReducer1 = 'helloReducer1';
    String helloReducer2 = 'helloReducer2';
    String reducer1Reporting = 'reducer 1 reporting';
    String reducer2Reporting = 'reducer 2 reporting';

    Reducer<String, String> reducer1 = (String state, String action) {
      if (action == helloReducer1) {
        return reducer1Reporting;
      }

      return state;
    };

    Reducer<String, String> reducer2 = (String state, String action) {
      if (action == helloReducer2) {
        return reducer2Reporting;
      }

      return state;
    };

    Store<String, String> store = new Store(
        combineReducers(<Reducer<String, String>>[reducer1, reducer2]),
        initialState: intialState);

    expect(store.state, equals(intialState));
    store.dispatch(helloReducer1);
    expect(store.state, equals(reducer1Reporting));
    store.dispatch(helloReducer2);
    expect(store.state, equals(reducer2Reporting));
  });

  test('subscribers should be notified when the state changes', () {
    bool subscriber1Called = false;
    bool subscriber2Called = false;
    Reducer<String, String> reducer = (state, action) {
      return action;
    };
    Store<String, String> store =
        new Store(reducer, initialState: 'Hello', synchronousStream: true);

    store.onChange.listen((String state) {
      subscriber1Called = true;
    });

    store.onChange.listen((String state) {
      subscriber2Called = true;
    });

    store.dispatch("action");

    expect(subscriber1Called, isTrue);
    expect(subscriber2Called, isTrue);
  });

  test('cancelled subscriber should not be notified when the state changes',
      () {
    bool subscriber1Called = false;
    bool subscriber2Called = false;
    Reducer<String, String> reducer = (state, action) {
      return action;
    };
    Store<String, String> store =
        new Store(reducer, initialState: 'Hello', synchronousStream: true);

    store.onChange.listen((String state) {
      subscriber1Called = true;
    });

    StreamSubscription<String> subscription =
        store.onChange.listen((String state) {
      subscriber2Called = true;
    });

    subscription.cancel();

    store.dispatch("action");

    expect(subscriber1Called, isTrue);
    expect(subscriber2Called, isFalse);
  });

  test('store should pass the current state to subscribers', () {
    Reducer<String, String> reducer = (state, action) {
      return action;
    };
    final String action = 'test';
    String stateFromOnChangeListener = 'incorrectState';

    Store<String, String> store =
        new Store(reducer, initialState: 'Hello', synchronousStream: true);

    store.onChange.listen((String state) => stateFromOnChangeListener = state);

    store.dispatch(action);

    expect(stateFromOnChangeListener, equals(action));
  });
}
