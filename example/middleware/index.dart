import 'dart:html';
import 'dart:async';

import 'package:redux/redux.dart';

render(int state) {
  querySelector('#value').innerHtml = '${state}';
}

// Create a Reducer with a State (int) and an Action (String) Any dart object
// can be used for Action and State.
int counterReducer(int state, action) {
  switch (action) {
    case 'INCREMENT':
      return state + 1;
    case 'DECREMENT':
      return state - 1;
    default:
      return state;
  }
}

// A piece of middleware that will log all actions with a timestamp to your
// console!
loggingMiddleware(Store<int> store, action, NextDispatcher next) {
  print('${new DateTime.now()}: $action');

  next(action);
}

main() {
  // Create a new reducer and store for the app.
  final store = new Store<int>(
    counterReducer,
    initialState: 0,
    middleware: <Middleware<int>>[loggingMiddleware],
  );

  render(store.state);
  store.onChange.listen(render);

  querySelector('#increment').onClick.listen((_) {
    store.dispatch('INCREMENT');
  });

  querySelector('#decrement').onClick.listen((_) {
    store.dispatch('DECREMENT');
  });

  querySelector('#incrementIfOdd').onClick.listen((_) {
    if (store.state % 2 != 0) store.dispatch('INCREMENT');
  });

  querySelector('#incrementAsync').onClick.listen((_) {
    new Future.delayed(new Duration(milliseconds: 1000)).then((_) {
      store.dispatch('INCREMENT');
    });
  });
}
