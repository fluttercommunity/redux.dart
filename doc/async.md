# Handling Async Code with Middleware

In the [basics guide](https://github.com/johnpryan/redux.dart/blob/master/doc/basics.md), we built a simple todo application. It was fully synchronous. Every time an action was dispatched, the state was updated immediately.

However, what if we wanted to Load our Todos from storage or a web service? This is where `Middleware` come in.

## Actions

When you call an asynchronous API, there are two crucial moments in time: the moment you start the call, and the moment when you receive an answer (or a timeout).

Each of these two moments usually require a change in the application state; to do that, you need to dispatch normal actions that will be processed by reducers synchronously. Usually, for any API request you'll want to dispatch at least three different kinds of actions:

  * **An action informing the reducers that the request began.**
  The reducers may handle this action by toggling an isFetching flag in the state. This way the UI knows it's time to show a spinner.

  * **An action informing the reducers that the request finished successfully.**
  The reducers may handle this action by merging the new data into the state they manage and resetting isFetching. The UI would hide the spinner, and display the fetched data.

  * **An action informing the reducers that the request failed.**
  The reducers may handle this action by resetting isFetching. Additionally, some reducers may want to store the error message so the UI can display it.
  
Let's see what these actions look like in code form:

```dart
class FetchTodosAction {}

class FetchTodosSucceededAction {
  final List<Todo> fetchedTodos;
  
  FetchTodosSucceededAction(this.fetchedTodos);
}

class FetchTodosFailedAction {
  final Exception error;
  
  FetchTodosFailedAction(this.error);
}
```

## State Shape

In order to display `fetching` and `error` states in our UI, we'll need to update our `AppState` from the [basics](https://github.com/johnpryan/redux.dart/blob/master/doc/basics.md) example with two new fields: `isFetching` and `error`. 

```dart
class AppState {
  List<Todo> todos;
  VisibilityFilter visibilityFilter;
  bool isFetching;
  Exception error;
  
  AppState({ 
    this.todos = const [], 
    this.visibilityFilter = VisibilityFilter.showAll,
    this.isFetching = false,
    this.error,
  });
}
```

## Reducer

Now, we'll need to write a reducer that handles these actions and updated state!

```dart
AppState todosReducer(AppState state, action) {
  if (action is FetchTodosAction) {
    return new AppState(
      todos: state.todos,
      visibilityFilter: state.visibilityFilter,
      
      // This is the important bit! Set `isFetching` to true so our
      // UI can read this and show a loading spinner
      isFetching: true,
      // Ensure any previous error is removed
      error: null
    );
  } else if (action is FetchTodosSucceededAction) {
    return new AppState(
      // Set our actions to the fetched Todos
      todos: action.fetchedTodos,
      // Toggle isFetching to false so our UI will render the todos 
      // instead of a loading spinner.
      isFetching: false,
      // Ensure no error exists
      error: null,
      visibilityFilter: state.visibilityFilter,
    );    
  } else if (action is FetchTodosFailedAction) {
    return new AppState(
      // Set our actions to an empty value
      todos: const [],
      // Toggle isFetching to false
      isFetching: false,
      // Provide the error the state. Your UI can transform this 
      // error into an error message, depending on the type of
      // Exception 
      error: action.error,
      visibilityFilter: state.visibilityFilter,
    );    
  }
  
  return state;
}
```

Cool -- so now we have a Reducer that handles async actions. But where do the `FetchTodosSucceededAction` come from? Do we dispatch them ourselves? Nope, our `Middleware` handles that :)

## Middleware

Middleware are special functions that run *before* your dispatched actions reach your reducer. They can be used to listen for different actions and perform async calls, such as talking to a web server. Once they get a response from the web server, the can dispatch our `Success` or `Failure` actions!

Let's see how this works.

```dart
import 'package:redux/redux.dart';

// A middleware takes in 3 parameters: your Store, which you can use to
// read state or dispatch new actions, the action that was dispatched, 
// and a `next` function. The first two you know about, and the `next` 
// function is responsible for sending the action to your Reducer, or 
// the next Middleware if you provide more than one.
//
// Middleware do not return any values themselves. They simply forward
// actions on to the Reducer or swallow actions in some special cases.
void fetchTodosMiddleware(Store<AppState> store, action, NextDispatcher next) {
  // If our Middleware encounters a `FetchTodoAction`
  if (action is FetchTodosAction) {
    final api = new TodosApi(); // Create our pseudo-api for fetching todos
    
    // Use the api to fetch the todos
    api.fetchTodos().then((List<Todo> todos) {
      // If it succeeds, dispatch a success action with the todos.
      // Our reducer will then update the State using these todos.
      store.dispatch(new FetchTodosSucceededAction(todos));
    }).catchError((Exception error) {
      // If it fails, dispatch a failure action. The reducer will
      // update the state with the error.
      store.dispatch(new FetchTodosFailedAction(error));
    });  
  }
  
  // Make sure our actions continue on to the reducer.
  next(action);
}
```

## Kicking it all off

Now we have everything in place! All that's left to do is dispatch a `FetchTodosAction` from somewhere in your app!

```dart
import 'package:redux/redux.dart';

main() {
  // Create a Store with our Reducers, AppState, AND middleware function
  final store = new Store(
    todosReducer, 
    initialState: new AppState(), 
    middleware: [fetchTodosMiddleware],
  );
  
  // Dispatch the FetchTodosAction.
  store.dispatch(new FetchTodosAction());
  
  // Before the API returns results, we can read the state
  print(store.state.isFetching); // prints "True"
  print(store.state.todos); // prints an empty list
  
  // After the API returns, it should update the state
  print(store.state.isFetching); // prints "False" now
  print(store.state.todos); // prints a list of fetched todos
}
```

## Data Flow

Now that our store contains middleware, let's understand the new data flow:

  1. *You call* `store.dispatch(Action)`
  2. The *Redux Store* calls *your middleware*
  3. *Your Middleware* starts an API call, and calls `next` to forwards the `FetchTodos` action to the reducer
  4. *Your Reducer* will return a new `AppState` with `isFetching` set to `true`.
  5. The *Redux Store* will save the new `AppState` and notify all components listening to the `onChange` Stream that a new `AppState` exists.
  6. When the the API call completes, *your middleware* will `dispatch` a `success` or `failure` action to the reducer.
  7. *Your Reducer* will update the state in response to success or failure, and set `isFetching` to `false`.
  8. The *Redux Store* will save the new `AppState` and notify all components listening to the `onChange` Stream that a new `AppState` exists.
  
## Pre-built Middleware

For common tasks and handling async code, it can be nice to use some utility libraries that provide additional functionality or that cut down on how much code you have to write.

Here are some helpful middleware for dealing with Async Actions:

  * [redux_thunk](https://pub.dartlang.org/packages/redux_thunk) - Redux Middleware for handling functions as actions
  * [redux_future](https://pub.dartlang.org/packages/redux_future) - Redux Middleware for handling Dart Futures as actions
  * [redux_epics](https://pub.dartlang.org/packages/redux_epics) - Redux Middleware to support the use of Streams

## Credits

This section borrows heavily from the original [ReduxJS docs](https://redux.js.org/docs/advanced/AsyncActions.html).

