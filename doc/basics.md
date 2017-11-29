# Redux.dart Basics

This page attempts to give you a high-level overview of how to use Redux. It covers:

  * [Actions](#actions)
  * [Reducers](#reducers)
  * [Handling Actions with Reducers](#handling-actions-with-reducers)
  * [Stores](#store)
  * [Data flow](#data-flow)

## Actions

First, let's define some actions.

*Actions* are payloads of information that send data from your application to your store. They are the only source of information for the store. You send them to the store using store.dispatch().

Here's an example action which represents adding a new todo item:

```dart
class AddTodoAction {
  final Todo todo;
  
  AddTodo(this.todo);
}
```

You can also use Enums, for actions that do not contain a payload:

```dart
enum VisibilityFilter {
  showAll,
  showActive,
  showCompleted
}
```

In Dart, your actions should be simple Enums, or classes if the Action contains payload information. 

If you come from ReduxJS:

  * We do not recommend creating an `Action` with a `type` String. An additional `type` String is unnecessary, leads to more code, and is not Type-safe.
  * There's no need for "action creators." You just create an instance of your action, e.g. `new AddTodoAction(new Todo("Hello"))`

Simple as that! Next up, we'll define our Reducer 

## Reducers

Actions describe the fact that something happened, but don't specify how the application's state changes in response. This is the job of reducers.

### Designing the State Shape

In Redux, all the application state is stored as a single object. It's a good idea to think of its shape before writing any code. What's the minimal representation of your app's state as an object?

For our todo app, we want to store two different things:

  * The currently selected visibility filter;
  * The actual list of todos.

You'll often find that you need to store some data, as well as some UI state, in the state tree. This is fine, but try to keep the data separate from the UI state.

```dart
// Define a Todo Class
class Todo {
  String task;
  bool completed;
  
  Todo(this.task, {this.completed = false});
}

// Define an AppState class that contains a List of Todos and the VisibilityFilter. 
class AppState {
  List<Todo> todos;
  VisibilityFilter visibilityFilter;
  
  // The AppState constructor can contain default values. No need to define these in another
  // place, like the Reducer.
  AppState({ 
    this.todos = const [], 
    this.visibilityFilter = VisibilityFilter.showAll,
  });
}
```

### Handling Actions with Reducers

Now that we've decided what our state object looks like, we're ready to write a reducer for it. The reducer is a pure function that takes the previous state and an action, and returns a new state.

In pseudo-code:

```dart
(AppState previousState, action) => newState
```

It's very important that the reducer stays pure. Things you should never do inside a reducer:

  * Mutate its arguments
  * Perform side effects like API calls and routing transitions
  * Call non-pure functions
  
We'll explore how to perform these types of functions in the [async walkthrough](./async.md). For now, just remember that the reducer must be pure. Given the same arguments, it should calculate the next state and return it. No surprises. No side effects. No API calls. No mutations. Just a calculation.

With this out of the way, let's start writing our reducer by gradually teaching it to understand the actions we defined earlier.

```dart
AppState todosReducer(AppState state, action) {
  // Check to see if the dispatched Action is an AddTodoAction
  if (action is AddTodoAction) {
    // If it is, add the todo to our list!
    return new AppState(
      // We don't mutate the previous list! We copy it and THEN add the new todo.
      todos: new List.from(state.todos)..add(action.todo),
      // Don't modify the value of visibilityFilter, just use the previous value
      visibilityFilter: state.visibilityFilter
    );
  } else if (action is VisibilityFilter) {
    // If the action is a VisibilityFilter
    return new AppState(
      // Do not update the list of todos
      todos: state.todos,
      // DO update the visibilityFilter
      visibilityFilter: action
    );
  } else {
    return state;
  }
}
```

Note that:

  * We don't mutate the state. We create a new copy every time!
  * We don't mutate lists. We create a new copy every time.
  * We return the previous state if our reducer doesn't match any actions. It's important to return the previous state for any unknown action.

As reducers grow in complexity and need to handle more and more actions, it can be helpful to break them down into smaller parts. For more information, see the article on [Combining Reducers](./combine_reducers.md)

## Store

In the previous sections, we defined the actions that represent the facts about “what happened” and the reducers that update the state according to those actions.

The Store is the object that brings them together. The store has the following responsibilities:

  * Holds application state;
  * Allows you to set the initialState 
  * Allows access to state via the `state` getter;
  * Allows state to be updated via `dispatch(action)`
  * Registers state change listeners via `onChange.listen()`

It's important to note that you'll only have a single store in a Redux application. When you want to split your data handling logic, you'll use reducer composition instead of many stores.

### Creating the Store

It's easy to create a store if you have a Store class and reducer. We'll use the `AppState` and `todosReducer` from our previous example!

```dart
import 'package:redux/redux.dart';

main() {
  final store = new Store<AppState>(todosReducer, initialState: new AppState());
}
```

### Reading state from the store

To read state, simply access the `state` getter, which will return the latest instance of your `AppState` class!

```dart
import 'package:redux/redux.dart';

main() {
  final store = new Store<AppState>(todosReducer, initialState: new AppState());
  
  print(store.state.todos); // Prints an empty list
  print(store.state.visibilityFilter); // Prints "VisibilityFilter.showAll"
  
  // **Wouldn't compile!** 
  // 
  // Dart knows the AppState class does not contain a `lolNotHere` field and
  // will warn you in your Editor!
  print(store.state.lolNotHere); 
}
```

### Dispatching Actions

Once you have a store and an action, you'll want to dispatch it to your `Store` so your reducer can act upon it. You do so using the `store.dispatch` method.

```dart
import 'package:redux/redux.dart';

main() {
  final store = new Store<AppState>(todosReducer, initialState: new AppState());
  
  print(store.state.todos); // Prints an empty list
  print(store.state.visibilityFilter); // Prints "VisibilityFilter.showAll"
  
  // Now we'll dispatch actions, that run through the `todosReducer`, 
  // and updates the AppState 
  store.dispatch(new AddTodoAction(new Todo("Hello")));
  store.dispatch(VisibilityFilter.showActive);
  
  // Access the state after the actions have been dispatched to the reducer
  print(store.state.todos); // Prints a list with one item: the "Hello" todo
  print(store.state.visibilityFilter); // prints VisibilityFilter.showActive
}
```

## Data Flow

To understand how this all fits together, let's take a look at the data flow:

  1. *You call* `store.dispatch(Action)`
  2. The *Redux Store* calls *your reducer* with the previous state and dispatched action
  3. *Your Reducer* will return a new `AppState`
  4. The *Redux Store* will save the new `AppState` and notify all components listening to the `onChange` Stream that a new `AppState` exists.
  5. When the State changes, *you rebuild your UI* with the new State. Often this is rebuilding is handled for you by something like [flutter_redux](https://pub.dartlang.org/packages/flutter_redux).
  

## Credits

This page borrows heavily from the original [ReduxJS docs](https://redux.js.org/docs/basics), and applies them to Dart.
