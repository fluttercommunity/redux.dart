import 'dart:async';

/// Defines an application's state change
///
/// Implement this class to modify your app state in response to a given action.
///
/// Example:
///
///     class Counter extends Reducer<int, String> {
///       reduce(int state, String action) {
///         switch (action) {
///           case 'INCREMENT':
///             return state + 1;
///           case 'DECREMENT':
///             return state - 1;
///           default:
///             return state;
///         }
///       }
///     }
abstract class Reducer<State, Action> {
  State reduce(State state, Action action);
}

/// Defines a piece of middleware.
///
/// Middleware intercept actions before they reach the reducer. This gives them
/// the ability to produce side-effects or modify the passed in action before
/// they reach the reducer.
///
/// Example:
///
///    class LoggingMiddleware implements Middleware<int, String> {
///      call(Store<int, String> store, String action, next) {
///        print('${new DateTime.now()}: $action');
///
///        next(action);
///      }
///    }
abstract class Middleware<State, Action> {
  call(Store<State, Action> store, Action action, NextDispatcher next);
}

/// The contract between one piece of middleware and the next in the chain.
///
/// Middleware can optionally pass the original action or a modified action to
/// the next piece of middleware, or never call the next piece of middleware at
/// all.
///
/// This class is an implementation detail, and should never be constructed by a
/// user of this library.
typedef void NextDispatcher<Action>(Action action);

/// Manages applying the reducer to the application state.
/// Emits an [onChange] event when the state changes.
class Store<State, Action> {
  State _state;
  Reducer<State, Action> reducer;
  StreamController<State> _changeController;
  List<NextDispatcher<Action>> _dispatchers;

  Store(this.reducer,
      {State initialState,
      List<Middleware<State, Action>> middleware: const [],
      bool syncStream: false})
      : _changeController = new StreamController.broadcast(sync: syncStream) {
    _state = initialState;
    _dispatchers = _createDispatchers(middleware);
  }

  /// Returns the current state of the app
  State get state => _state;

  /// A stream that emits the current state when it changes.
  Stream<State> get onChange => _changeController.stream;

  // The base [NextDispatcher].
  //
  // This will be called after all other middleware provided by the user have
  // been run. Its job is simple: Run the current state through the reducer,
  // save the result, and notify any subscribers.
  _reduceAndNotify(Action action) {
    var state = reducer.reduce(_state, action);
    _state = state;
    _changeController.add(state);
  }

  List<NextDispatcher> _createDispatchers(
      List<Middleware<State, Action>> middleware) {
    List<NextDispatcher> dispatchers = [];

    // Add _reduceAndNotify as our base dispatcher
    dispatchers.add(_reduceAndNotify);

    // Convert each [Middleware] into a [NextDispatcher]
    for (var nextMiddleware in middleware.reversed) {
      var next = dispatchers.last;
      var dispatcher = (Action action) => nextMiddleware(this, action, next);
      dispatchers.add(dispatcher);
    }

    return dispatchers.reversed.toList();
  }

  /// Runs the action through all provided [Middleware], then applies an action
  /// to the state using the given [Reducer]. Please note: [Middleware] can
  /// intercept actions, and can modify actions or stop them from passing
  /// through to the reducer.
  void dispatch(Action action) {
    _dispatchers[0](action);
  }
}

/// Defines a utility function that combines several reducers.
///
/// In order to prevent having one large, monolithic reducer in your app, it can
/// be convenient to break reducers up into smaller parts that handle more
/// specific functionality that can be decoupled and easily tested.
///
/// Example:
///
///     class HelloReducer {
///       reduce(state, action) {
///         return "hello";
///       }
///     }
///
///     class FriendReducer
///       reduce(state, action) {
///         return state + " friend";
///       }
///     }
///
///     Reducer<String, String> helloFriendReducer = new CombinedReducer(new
///       HelloReducer(), new FriendReducer());
class CombinedReducer<State, Action> implements Reducer<State, Action> {
  List<Reducer<State, Action>> _reducers;

  CombinedReducer(Iterable<Reducer<State, Action>> reducers) {
    _reducers = new List.from(reducers);
  }

  State reduce(State state, Action action) {
    for (var reducer in _reducers) {
      state = reducer.reduce(state, action);
    }
    return state;
  }
}
