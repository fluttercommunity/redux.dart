# redux.dart

[Redux](http://redux.js.org/) for Dart using generics for
typed Actions and State.

## Usage

```dart
// Create a Reducer with a State (int) and an Action (String)
// Any dart object can be used for Action and State.
class Counter extends Reducer<int, String> {
  reduce(int state, String action) {
    switch (action) {
      case 'INCREMENT':
        return state + 1;
      case 'DECREMENT':
        return state - 1;
      default:
        return state;
    }
  }
}

main() {
  // Create a new reducer and store for the app.
  var reducer = new Counter();
  var store = new Store(reducer, initialState: 0);

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

see the `examples/` directory for details.
