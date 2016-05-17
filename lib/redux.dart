import 'dart:async';

/// Defines an application's state change
/// Override this class to implement your
/// application's reduce() function.
abstract class Reducer<State, Action> {
  State reduce(State state, Action action);
}

/// Manages applying the reducer to the application state.
/// Emits an [onChange] event when the state changes.
class Store<State, Action> {
  /// The current state of the application
  State _state;
  State get state => _state;
  Reducer<State, Action> reducer;
  StreamController<State> _changeController;

  Store(this.reducer, {State initialState}) :
    _changeController = new StreamController.broadcast() {
    _state = initialState;
  }

  /// Emits the current state when it changes.
  Stream<State> get onChange => _changeController.stream;

  /// Applies an action to the state using the [Reducer]
  void dispatch(Action action) {

    // Reduce and set the new state on the Reducer
    var result = reducer.reduce(_state, action);
    _state = result;
    _changeController.add(result);

  }
}

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