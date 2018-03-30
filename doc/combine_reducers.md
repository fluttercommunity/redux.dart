# Combining Reducers

If you have a simple app, such as a `Counter` app with a small State tree, you might be fine using a single Reducer for your app. However, as your app grows, you'll often want to split your app up into many smaller parts so you and your teammates can focus on one feature at a time. It also makes testing much simpler!

This generally means you'll want to break your Reducer down into smaller functions that each handle a certain part of the state tree.

Redux.JS comes with a utility function to conveniently merge a set of State keys with a given reducer. Unfortunately, this doesn't work so well in the land of Dart!

Why not, you ask? Because Dart works best with Strong Typing! This means you get some great tooling support for refactoring and better hinting within your Code Editor (if you try to access a piece of state that doesn't exist, you will see the error right in your Editor)! 

So how do we compose large state trees: Simple Function Composition! Let's take a look at a "Before" and "After" example of how to compose state trees.

## One Big Reducer.

First, we'll take a look at a reducer that handles a few different cases.

```dart
// Define your State
class AppState {
  final List<String> items;
  final String searchQuery;

  AppState(this.items, this.searchQuery);
}

// Define your Actions
class AddItemAction {
  String item;
}

class PerformSearchAction {
  String query;
}

// Create your single reducer to handle all of the actions. This is 
// a simple example for demonstration purposes, as your app grows this
// will get much more complex as it handles more and more actions. 
AppState reducer(AppState state, action) {
  // This library recommends using Individual Classes or Enums for Actions
  // and performing `is MyAction` checks in your Reducers as opposed to 
  // comparing Strings, such as `action.type == "MyAction"`.
  //
  // Why? 
  // 
  //   1. Type safety. You can only match the exact action you care
  //   about. With Strings, if you aren't careful with naming, you might 
  //   accidentally duplicate the name of another action.
  //   2. The `action` will be cast the `action` for you within the `if` block
  //   3. `action is AddItemAction` is faster than comparing Strings! 
  if (action is AddItemAction) {
    return new AppState(
      new List.from(state.items)..add(action.item), 
      state.searchQuery,
    );
  } else if (action is RemoveItemAction) {
    return new AppState(
      new List.from(state.items)..remove(action.item), 
      state.searchQuery,
    );
  } else if (action is PerformSearchAction) {
    return new AppState(state.items, action.query);
  } else {
    return state;
  }
}
```

## Combining Reducers

Now, let's take a look at this same example with function composition. The app state reducer will work exactly as it 
did before, but we'll break the reducer down into smaller parts.

This will make it easier to split up and test your app, and even means you can move the reducer functions into their own 
directories or even separate Dart packages!

In this case, assume we're using the same `State` and `Action` classes from above.

```dart
// Individual Reducers. Each reducer will handle actions related to the State Tree it cares about!

// The Items Reducer will take in the items from the State tree and the dispatched action and
// return a new list of items if it handles the action! 
List<String> itemsReducer(List<String> items, action) {
  if (action is AddItemAction) {
    // Notice how we don't need to recreate the entire state tree! We just focus
    // on returning a new List of Items. 
    return new List.from(items)..add(action.item);
  } else if (action is RemoveItemAction) {
    return new List.from(items)..remove(action.item);
  } else {
    return items;
  }
}

// This reducer will take in the current search query and the action, and update the query
// if the action is a `PerformSearchAction`
String searchQueryReducer(String searchQuery, action) {
  return action is PerformSearchAction ? action.query : searchQuery;
}

// Put em together. In this case, we'll create a new app state every time an action 
// is dispatched (remember, this should be a pure function!), but we'll use our
// smaller reducer functions instead.
//
// Since our `AppState` constructor has two parameters: `items` and `searchQuery`,
// and our reducers return these types of values, we can simply call those reducer
// functions with the part of the State tree they care about and the current action.
//
// Each reducer will take in the part of the state tree they care about and the
// current action, and return the new list of items or a new search query for 
// the constructor!
AppState appStateReducer(AppState state, action) => new AppState(
  itemsReducer(state.items, action),
  searchQueryReducer(state.searchQuery, action)
);
```

## Going Further

Some readers might see that we can actually break down our `itemsReducer` into smaller functions! While it's quite 
simple now, if we begin to add more and more actions, it might get a bit confusing.

The power of function composition is that it can go infinitely deep! We can continue to create smaller and smaller
reducers and compose them together in more complex functions.

In addition, by splitting up our Reducers, we can guarantee type-safety in the smaller functions by checking & casting
the Action before we call the smaller reducer function.

Let's take a look at how to do just that!

```dart
// In this case, we'll split our `itemsReducer` into an `addItemReducer` 
// and a `removeItemReducer`. We can also do some type-checking *before* 
// calling the reducer. This will allow our even smaller reducer functions
// to handle actions of only a certain type!
//
// Notice the `AddItemAction` type-annotation in the params.
List<String> addItemReducer(List<String> items, AddItemAction action) {
  return new List.from(items)..add(action.item);
}

List<String> removeItemReducer(List<String> items, RemoveItemAction action) {
  return new List.from(items)..remove(action.item);
}

// Compose these smaller functions into the full `itemsReducer`.
List<String> itemsReducer(List<String> items, action) {
  if (action is AddItemAction) {
    return addItemsReducer(items, action);
  } else if (action is RemoveItemAction) {
    return removeItemsReducer(items, action);
  } else {
    return items;
  }
}

// Use the new itemsReducer just like we did before
AppState appStateReducer(AppState state, action) => new AppState(
  itemsReducer(state.items, action),
  searchQueryReducer(state.searchQuery, action)
); 
```

## Reducing Boilerplate in a Type Safe Way

Now that we know how to compose (combine) reducers, we can look at some utilities in this library to help make this
process easier.

We'll focus on two utilities included with Redux: `combineReducers` and `TypedReducer`s.

In this example, our `itemsReducer` will be created by the `combineReducers` function. Instead of checking for each
type of action and calling it manually, we can setup a list of `TypedReducer`s.

```dart
// Start with our same type-safe, smaller reducers we had before.
List<String> addItemReducer(List<String> items, AddItemAction action) {
  return new List.from(items)..add(action.item);
}

List<String> removeItemReducer(List<String> items, RemoveItemAction action) {
  return new List.from(items)..remove(action.item);
}

// Compose these smaller functions into the full `itemsReducer`.
Reducer<List<String>> itemsReducer = combineReducers([
  // Each `TypedReducer` will glue Actions of a certain type to the given 
  // reducer! This means you don't need to write a bunch of `if` checks 
  // manually, and can quickly scan the list of `TypedReducer`s to see what 
  // reducer handles what action.
  new TypedReducer<List<String>, AddItemAction>(addItemReducer),
  new TypedReducer<List<String>, RemoveItemAction>(removeItemReducer),
]);

// Use the new itemsReducer just like we did before
AppState appStateReducer(AppState state, action) => new AppState(
  itemsReducer(state.items, action),
  searchQueryReducer(state.searchQuery, action)
);
```

### Summary, aka "all the way down the rabbit hole"

We saw how to:

  1. Use Type-safe state as a starting point.
  2. Compose reducers together to update that state in response to actions
  3. Break our reducers down into smaller bits
  4. Break those smaller bits into *even smaller bits*!!!

Remember: You could nest this type of logic infinitely deep. This can help make your code:

  1. Easy to Read
  2. Easy to test
  3. Safe to modify 

You can choose to use the utilities in this Library if you find them helpful, or simply write your own functions if that's clearer. Either way, the power of functional composition allows us to nest this pattern as much as we need!

Enjoy :)
