import 'dart:async';

/// Defines an application's state change
///
/// Implement this typedef to modify your app state in response to a given
/// action.
///
/// ### Example
///
///     int counterReducer(int state, action) {
///       switch (action) {
///         case 'INCREMENT':
///           return state + 1;
///         case 'DECREMENT':
///           return state - 1;
///         default:
///           return state;
///       }
///     }
///
///     final store = new Store<int>(counterReducer);
typedef State Reducer<State>(State state, dynamic action);

/// Defines a [Reducer] using a class interface.
///
/// Implement this class to modify your app state in response to a given action.
///
/// For some use cases, a class may be preferred to a function. In these
/// instances, a ReducerClass can be used.
///
/// ### Example
///
///     class CounterReducer extends ReducerClass<int> {
///       int call(int state, action) {
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
///
///     final store = new Store<int>(new CounterReducer());
abstract class ReducerClass<State> {
  State call(State state, dynamic action);
}

/// A function that intercepts actions before they reach the reducer.
///
/// Middleware intercept actions before they reach the reducer. This gives them
/// the ability to produce side-effects or modify the passed in action before
/// they reach the reducer.
///
/// ### Example
///
///     loggingMiddleware(Store<int> store, action, next) {
///       print('${new DateTime.now()}: $action');
///
///       next(action);
///     }
///
///     // Create your store with the loggingMiddleware
///     final store = new Store<int>(
///       counterReducer,
///       middleware: [loggingMiddleware],
///     );
typedef void Middleware<State>(
  Store<State> store,
  dynamic action,
  NextDispatcher next,
);

/// Defines a [Middleware] using a Class interface.
///
/// Middleware intercept actions before they reach the reducer. This gives them
/// the ability to produce side-effects or modify the passed in action before
/// they reach the reducer.
///
/// For some use cases, a class may be preferred to a function. In these
/// instances, a MiddlewareClass can be used.
///
/// ### Example
///     class LoggingMiddleware extends MiddlewareClass<int> {
///       call(Store<int> store, action, next) {
///         print('${new DateTime.now()}: $action');
///
///         next(action);
///       }
///     }
///
///     // Create your store with the loggingMiddleware
///     final store = new Store<int>(
///       counterReducer,
///       middleware: [loggingMiddleware],
///     );
abstract class MiddlewareClass<State> {
  void call(Store<State> store, dynamic action, NextDispatcher next);
}

/// The contract between one piece of middleware and the next in the chain.
///
/// Middleware can optionally pass the original action or a modified action to
/// the next piece of middleware, or never call the next piece of middleware at
/// all.
///
/// This class is an implementation detail, and should never be constructed by a
/// user of this library.
typedef void NextDispatcher(dynamic action);

/// Manages applying the reducer to the application state.
///
/// Emits an [onChange] event when the state changes.
///
/// ### Example
///
///     final store = new Store<int>(
///       counterReducer,
///       initialState: 0,
///       middleware: [loggingMiddleware]
///     }
class Store<State> {
  State _state;
  Reducer<State> reducer;
  StreamController<State> _changeController;
  List<NextDispatcher> _dispatchers;

  Store(this.reducer,
      {State initialState,
      List<Middleware<State>> middleware: const [],
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
  _reduceAndNotify(dynamic action) {
    final state = reducer(_state, action);
    _state = state;
    _changeController.add(state);
  }

  List<NextDispatcher> _createDispatchers(List<Middleware<State>> middleware) {
    List<NextDispatcher> dispatchers = [];

    // Add _reduceAndNotify as our base dispatcher
    dispatchers.add(_reduceAndNotify);

    // Convert each [Middleware] into a [NextDispatcher]
    for (var nextMiddleware in middleware.reversed) {
      final next = dispatchers.last;
      final dispatcher = (dynamic action) => nextMiddleware(this, action, next);
      dispatchers.add(dispatcher);
    }

    return dispatchers.reversed.toList();
  }

  /// Runs the action through all provided [Middleware], then applies an action
  /// to the state using the given [Reducer]. Please note: [Middleware] can
  /// intercept actions, and can modify actions or stop them from passing
  /// through to the reducer.
  void dispatch(dynamic action) {
    _dispatchers[0](action);
  }

  /// Disposes the Store.
  Future<dynamic> dispose() => _changeController.close();
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
Reducer<State> combineReducers<State>(Iterable<Reducer<State>> reducers) {
  return (State state, dynamic action) {
    for (final reducer in reducers) {
      state = reducer(state, action);
    }
    return state;
  };
}
