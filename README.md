# redux.dart

[Redux](http://redux.js.org/) for Dart using generics for typed State.

## Web Examples

See the `example/` directory to for a few simple examples of the basics of Redux.

To launch the examples in your browser:

  1. Run `pub serve example` from this directory
  2. Open [http://localhost:8080](http://localhost:8080)

## Flutter Integration

See the [flutter_redux](https://pub.dartlang.org/packages/flutter_redux) library for a set of Widgets custom made to work with Redux.

## Usage

```dart
import 'package:redux/redux.dart';

// Create a Reducer with a State (int) and an Action (String)
// Any dart object can be used for Action and State.
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

// A piece of middleware that will log all actions with a timestamp
// to your console!
loggingMiddleware(Store<int> store, action, next) {
  print('${new DateTime.now()}: $action');

  next(action);
}


main() {
  final store = new Store<int>(
    reducer, 
    initialState: 0, 
    middleware: [loggingMiddleware],
  );

  // Render our State right away
  render(store.state);
  
  // Listen to store changes, and re-render when the state is updated
  store.onChange.listen(render);

  // Attach a click handler to a button. When clicked, the `INCREMENT` action
  // will be dispatched. It will then run through the reducer, updating the 
  // state.
  //
  // After the state changes, the html will be re-rendered by our `onChange`
  // listener above. 
  querySelector('#increment').onClick.listen((_) {
    store.dispatch('INCREMENT');
  });
}

render(int state) {
  querySelector('#value').innerHtml = '${state}';
}
```
