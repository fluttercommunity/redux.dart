import 'package:redux/src/store.dart';

/// A type safe Reducer
typedef TypedReducer<State, Action> = State Function(
  State state,
  Action action,
);

/// A class that binds an Action of a given type to a specific TypedReducer
class ReducerBinding<State, Action> {
  final TypedReducer<State, Action> reducer;

  ReducerBinding(this.reducer);

  bool handlesAction(dynamic action) {
    return action is Action;
  }
}

/// A convenience function for binding Reducers to Actions of a given Type. This
/// allows for type safe [Middleware] and reduces boilerplate.
///
/// ### Example
///
/// In order to see what this utility function does, let's take a look at a
/// regular example of using reducers based on the Type of an action.
///
/// ```
/// // We define out State and Action classes.
/// class AppState {
///   final List<Item> items;
///
///   AppState(this.items);
/// }
///
/// class LoadItemsAction {}
/// class UpdateItemsAction {}
/// class AddItemAction{}
/// class RemoveItemAction {}
/// class ShuffleItemsAction {}
/// class ReverseItemsAction {}
/// class ItemsLoadedAction<Item> {
///   final List<Item> items;
///
///   ItemsLoadedAction(this.items);
/// }
///
/// // Then we define our reducer. Since we handle different actions in our
/// // reducer, we need to determine what kind of action we're working with
/// // using if statements, and then run some computation in response.
/// //
/// // This isn't a big deal if we have relatively few cases to handle, but your
/// // reducer function can quickly grow large and take on too many
/// // responsibilities as demonstrated here with pseudo-code.
/// final appReducer = (AppState state, action) {
///   if (action is ItemsLoadedAction) {
///     return new AppState(action.items);
///   } else if (action is UpdateItemsAction) {
///     return ...;
///   } else if (action is AddItemAction) {
///     return ...;
///   } else if (action is RemoveItemAction) {
///     return ...;
///   } else if (action is ShuffleItemsAction) {
///     return ...;
///   } else if (action is ReverseItemsAction) {
///     return ...;
///   } else {
///     return state;
///   }
/// };
/// ```
///
/// What would be nice would be to break our big reducer up into smaller
/// reducers. It would also be nice to bind specific Types of Actions to
/// specific reducers so we can ensure type safety for our reducers while
/// avoiding large trees of `if` statements.
///
/// ```
/// // First, we'll break out all of our individual State Changes into
/// // individual reducers. These can be easily tested or composed!
/// final loadItemsReducer = (AppState state, LoadTodosAction action) =>
///   return new AppState(action.items);
///
/// final updateItemsReducer = (AppState state, UpdateItemsAction action) =>
///   return ...;
///
/// final addItemReducer = (AppState state, AddItemAction action) =>
///   return ...;
///
/// final removeItemReducer = (AppState state, RemoveItemAction action) =>
///   return ...;
///
/// final shuffleItemsReducer = (AppState state, ShuffleItemAction action) =>
///   return ...;
///
/// final reverseItemsReducer = (AppState state, ReverseItemAction action) =>
///   return ...;
///
/// // We will then wire up specific types of actions to our reducer functions
/// // above. This will return a new Reducer<AppState> which puts everything
/// // together!.
/// final Reducer<AppState> appReducer = combineTypedReducers([
///   new ReducerBinding<AppState, LoadTodosAction>(loadItemsReducer),
///   new ReducerBinding<AppState, UpdateItemsAction>(updateItemsReducer),
///   new ReducerBinding<AppState, AddItemAction>(addItemReducer),
///   new ReducerBinding<AppState, RemoveItemAction>(removeItemReducer),
///   new ReducerBinding<AppState, ShuffleItemAction>(shuffleItemsReducer),
///   new ReducerBinding<AppState, ReverseItemAction>(reverseItemsReducer),
/// ]);
/// ```
Reducer<State, Action> combineTypedReducers<State, Action>(
    List<ReducerBinding<State, Action>> bindings) {
  return (State state, Action action) {
    return bindings.fold(state, (currentState, binder) {
      if (binder.handlesAction(action)) {
        return binder.reducer(state, action);
      } else {
        return currentState;
      }
    });
  };
}

/// A type safe Middleware.
typedef TypedMiddleware<State, Action> = void Function(
  Store<State, Action> store,
  Action action,
  NextDispatcher next,
);

/// A class that binds an Action of a given type to a specific TypedMiddleware
class MiddlewareBinding<State, Action> {
  final TypedMiddleware<State, Action> middleware;

  MiddlewareBinding(this.middleware);

  bool handlesAction(dynamic action) {
    return action is Action;
  }
}

/// A convenience function for binding a piece of Middleware to an Action
/// of a specific type. Allows for Type Safe Middleware and reduces boilerplate.
///
/// ### Example
///
/// In order to see what this utility function does, let's take a look at a
/// regular example of running Middleware based on the Type of an action.
///
/// ```
/// class AppState {
///   final List<Item> items;
///
///   AppState(this.items);
/// }
/// class LoadItemsAction {}
/// class UpdateItemsAction {}
/// class AddItemAction{}
/// class RemoveItemAction {}
/// class ShuffleItemsAction {}
/// class ReverseItemsAction {}
/// class ItemsLoadedAction<Item> {
///   final List<Item> items;
///
///   ItemsLoadedAction(this.items);
/// }
///
/// final loadItems = () { /* Function that loads a Future<List<Item>> */}
/// final saveItems = (List<Item> items) { /* Function that persists items */}
///
/// final middleware = (Store<AppState> store, action, NextDispatcher next) {
///   if (action is LoadItemsAction) {
///     loadItems()
///       .then((items) => store.dispatch(new ItemsLoaded(items))
///       .catchError((_) => store.dispatch(new ItemsNotLoaded());
///
///     next(action);
///   } else if (action is UpdateItemsAction ||
///       action is AddItemAction ||
///       action is RemoveItemAction ||
///       action is ShuffleItemsAction ||
///       action is ReverseItemsAction) {
///     next(action);
///
///     saveItems(store.state.items);
///   } else {
///     next(action);
///   }
/// };
/// ```
///
/// This works fine if you have one or two actions to handle, but you might
/// notice it's getting a bit messy already. Let's see how this lib helps clean
/// it up.
///
/// ```
/// // First, let's start by breaking up our functionality into two middleware
/// // functions.
/// //
/// // The loadItemsMiddleware will only handle the `LoadItemsAction`s that
/// // are dispatched, so we can annotate the Type of action.
/// final loadItemsMiddleware = (
///   Store<AppState> store,
///   LoadItemsAction action,
///   NextDispatcher next,
/// ) {
///   loadItems()
///     .then((items) => store.dispatch(new ItemsLoaded(items))
///     .catchError((_) => store.dispatch(new ItemsNotLoaded());
///
///   next(action);
/// }
///
/// // The saveItemsMiddleware handles all actions that change the Items, but
/// // does not depend on the payload of the action. Therefore, `action` will
/// // remain dynamic.
/// final saveItemsMiddleware = (
///   Store<AppState> store,
///   action,
///   NextDispatcher next,
/// ) {
///   next(action);
///
///   saveItems(store.state.items);
/// }
///
/// // We will then wire up specific types of actions to a List of Middleware
/// // that handle those actions.
/// final List<Middleware<AppState>> middleware = combineTypedMiddleware([
///   new MiddlewareBinder<AppState, LoadTodosAction>(loadItemsMiddleware),
///   new MiddlewareBinder<AppState, AddTodoAction>(saveItemsMiddleware),
///   new MiddlewareBinder<AppState, ClearCompletedAction>(saveItemsMiddleware),
///   new MiddlewareBinder<AppState, ToggleAllAction>(saveItemsMiddleware),
///   new MiddlewareBinder<AppState, UpdateTodoAction>(saveItemsMiddleware),
///   new MiddlewareBinder<AppState, TodosLoadedAction>(saveItemsMiddleware),
/// ]);
/// ```
List<Middleware<State, Action>> combineTypedMiddleware<State, Action>(
    List<MiddlewareBinding<State, Action>> bindings) {
  return bindings
      .map((binder) => (Store<State, Action> store, Action action,
              NextDispatcher<Action> next) {
            if (binder.handlesAction(action)) {
              return binder.middleware(store, action, next);
            } else {
              return next(action);
            }
          })
      .toList();
}

/// Defines a utility function that combines several reducers.
///
/// In order to prevent having one large, monolithic reducer in your app, it can
/// be convenient to break reducers up into smaller parts that handle more
/// specific functionality that can be decoupled and easily tested.
///
/// ### Example
///
///     helloReducer(state, action) {
///         return "hello";
///     }
///
///     friendReducer(state, action) {
///       return state + " friend";
///     }
///
///     final helloFriendReducer = combineReducers(
///       helloReducer,
///       friendReducer,
///     );
Reducer<State, Action> combineReducers<State, Action>(
    Iterable<Reducer<State, Action>> reducers) {
  return (State state, Action action) {
    for (final reducer in reducers) {
      state = reducer(state, action);
    }
    return state;
  };
}
