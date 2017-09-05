# redux.dart

[Redux](http://redux.js.org/) for Dart using generics for typed State. For complete documentation, view the [API Docs](https://www.dartdocs.org/documentation/redux/latest/). It includes a rich ecosystem of [Middleware](#middleware), [Dev Tools](#dev-tools) and [platform integrations](#platform-integrations).

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
// 
// Note, this is just an example of how to write your own Middleware.
// See the redux_logging package on pub for a pre-built logging 
// middleware.
loggingMiddleware(Store<int> store, action, NextDispatcher next) {
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

## Web Examples

See the `example/` directory to for a few simple examples of the basics of Redux.

To launch the examples in your browser:

  1. Run `pub serve example` from this directory
  2. Open [http://localhost:8080](http://localhost:8080)

## Flutter Examples

  * [Example in the flutter_redux](https://gitlab.com/brianegan/flutter_redux/tree/master/example) library. 

## Middleware

  * [redux_logging](https://pub.dartlang.org/packages/redux_logging) - Connects a [Logger](https://pub.dartlang.org/packages/logging) to a Store, and can print out actions as they're dispatched to your console.
  * [redux_thunk](https://pub.dartlang.org/packages/redux_thunk) - Allows you to dispatch functions that perform async work as actions.
  * [redux_future](https://pub.dartlang.org/packages/redux_future) - For handling Dart Futures that are dispatched as Actions.
  * [redux_epics](https://pub.dartlang.org/packages/redux_epics) - Middleware that allows you to work with Dart Streams of Actions to perform async work.

## Dev Tools

The [redux_dev_tools](https://pub.dartlang.org/packages/redux_dev_tools) library allows you to create a `DevToolsStore` during dev mode in place of a normal Redux `Store`. This `DevToolsStore` will act exactly like a normal `Store` at first, with one catch: It will allow you to travel back and forth throughout the State of your application!

You can combine the `DevToolsStore` with your own UI to travel in time, or use one of the existing options for the platform you're working with:

  * *Flutter* - [flutter_redux_dev_tools](https://pub.dartlang.org/packages/flutter_redux_dev_tools)
  * *Web* - No web UI exists yet. This could be you!

## Platform Integrations

  * [flutter_redux](https://pub.dartlang.org/packages/flutter_redux) - A library that connects Widgets to a Redux Store