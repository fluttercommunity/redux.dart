import 'dart:async';

/// Defines an application's state change
///
/// Create an implementation of this definition to modify
/// your app state in response to a given action.
///
/// Example:
///
///     Reducer<int, String> reducer(int state, String action) {
///       switch (action) {
///         case 'INCREMENT':
///           return state + 1;
///         case 'DECREMENT':
///           return state - 1;
///         default:
///           return state;
///       }
///     }
typedef State Reducer<State, Action>(State state, Action action);

/// Defines a piece of middleware.
///
/// Middleware intercept actions before they reach the
/// reducer. This gives them the ability to produce side-effects or modify
/// the passed in action before they reach the reducer.
///
/// Example:
///
///     Middleware<int, String> loggingMiddleware = (store, action, next) {
///       print('${new DateTime.now()}: $action');
///
///       next(action);
///     };
typedef void Middleware<State, Action>(
    Store<State, Action> store, Action action, NextDispatcher next);

/// The contract between one piece of middleware and the next in the chain.
///
/// Middleware can optionally pass the original action or a modified
/// action to the next piece of middleware, or never call the next
/// piece of middleware at all.
///
/// This class is an implementation detail, and should never be directly
/// created by a user of this library.
typedef void NextDispatcher<Action>(Action action);

/// Manages applying the reducer to the application state.
/// Emits an [onChange] event when the state changes.
class Store<State, Action> {
  State _currentState;
  List<NextDispatcher<Action>> _dispatchers;
  Reducer<State, Action> reducer;
  StreamController<State> _changeController;

  Store(this.reducer,
      {State initialState,
      List<Middleware<State, Action>> middleware: const [],

      // Useful for testing. If the stream is synchronous, it's very easy
      // to simply `store.dispatch` then run an `expect` clause without
      // fooling around with awkward expectAsync.
      bool synchronousStream: false})
      : _changeController =
            new StreamController.broadcast(sync: synchronousStream) {
    _currentState = initialState;
    _dispatchers = createDispatcherChain(middleware);
  }

  /// Returns the current state of the app
  State get state => _currentState;

  /// A stream that emits the current state when it changes.
  Stream<State> get onChange => _changeController.stream;

  // The base [NextDispatcher].
  //
  // This will be called after all other middleware
  // provided by the user have been run. Its job is simple: Run the current
  // state through the reducer, save the result, and notify any subscribers.
  _reduceAndNotify(Action action) {
    State result = reducer(_currentState, action);
    _currentState = result;
    _changeController.add(result);
  }

  List<NextDispatcher> createDispatcherChain(
      List<Middleware<State, Action>> middleware) {
    // Add _reduceAndNotify as our base dispatcher
    List<NextDispatcher> dispatchers = <NextDispatcher>[_reduceAndNotify];

    // Convert each [Middleware] into a [NextDispatcher]
    for (int i = middleware.length - 1; i >= 0; i--) {
      final Middleware<State, Action> nextMiddleware = middleware[i];
      final NextDispatcher next = dispatchers[0];

      dispatchers.insert(0, (Action action) {
        nextMiddleware(this, action, next);
      });
    }

    return dispatchers;
  }

  /// Runs the action through all provided [Middleware], then applies an
  /// action to the state using the given [Reducer]. Please note: [Middleware]
  /// can intercept actions, and can modify actions or stop them from
  /// passing through to the reducer.
  void dispatch(Action action) {
    _dispatchers[0](action);
  }
}

/// Defines a utility function that combines several reducers.
///
/// In order to prevent having one large, monolithic reducer in your app,
/// it can be convenient to break reducers up into smaller parts that handle
/// more specific functionality that can be decoupled and easily
/// tested.
///
/// Example:
///
///     Reducer<String, String> helloReducer(state, action) {
///       return "hello"
///     }
///
///     Reducer<String, String> friendReducer(state, action) {
///       return state + " friend"
///     }
///
///     Reducer<String, String> helloFriendReducer =
///       combineReducers(helloReducer, friendReducer)
Reducer<dynamic/*=State*/, dynamic/*=Action*/ >
    combineReducers/*<State, Action>*/(
        Iterable<Reducer<State, Action>> reducers) {
  return (state, action) {
    for (var reducer in reducers) {
      state = reducer(state, action);
    }

    return state;
  };
}
