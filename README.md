# redux.dart

[Redux](http://redux.js.org/) for Dart using generics for
typed Actions and State.

## Usage

```dart
import 'package:redux/redux.dart';

// Create a Reducer with a State (int) and an Action (String)
// Any dart object can be used for Action and State.
Reducer<int, String> reducer(int state, String action) {
  switch (action) {
    case 'INCREMENT':
      return state + 1;
    case 'DECREMENT':
      return state - 1;
    default:
      return state;
  }
}

// A piece of middleware that will log all actions with a timestamp
// to your console!
Middleware<int, String> loggingMiddleware = (store, action, next) {
  print('${new DateTime.now()}: $action');

  next(action);
};

main() {
  // Create a new store for the app.
  var store = new Store(reducer, initialState: 0, middleware: [middleware]);

  render(store.state);
  store.onChange.listen(render);

  querySelector('#increment').onClick.listen((_) {
    store.dispatch('INCREMENT');
  });
}

render(int state) {
  querySelector('#value').innerHtml = '${state}';
}
```

see the `example/` directory for details.  To run:

```
pub serve example
```
