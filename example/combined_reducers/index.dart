import 'dart:html';
import 'dart:async';

import 'package:redux/redux.dart';

render(AppState state) {
  querySelector('#value').innerHtml = '${state.count}';
  querySelector('#clickValue').innerHtml = '${state.clickCount}';
}

class AppState {
  final int count;
  final int clickCount;

  AppState(this.count, this.clickCount);
}

enum AppAction { increment, decrement }

// Create a Reducer with a State (int) and an Action (String) Any dart object
// can be used for Action and State.
AppState counterReducer(AppState state, action) {
  switch (action) {
    case AppAction.increment:
      return new AppState(state.count + 1, state.clickCount);
    case AppAction.decrement:
      return new AppState(state.count - 1, state.clickCount);
    default:
      return state;
  }
}

// Create a Reducer with a State (int) and an Action (String) Any dart object
// can be used for Action and State.
AppState clickCounterReducer(AppState state, action) {
  switch (action) {
    case AppAction.increment:
      return new AppState(state.count, state.clickCount + 1);
    case AppAction.decrement:
      return new AppState(state.count, state.clickCount + 1);
    default:
      return state;
  }
}

main() {
  // Create a new reducer and store for the app.
  final combined = combineReducers<AppState, AppAction>([
    counterReducer,
    clickCounterReducer,
  ]);
  final store = new Store<AppState, AppAction>(
    combined,
    initialState: new AppState(0, 0),
  );

  render(store.state);
  store.onChange.listen(render);

  querySelector('#increment').onClick.listen((_) {
    store.dispatch(AppAction.increment);
  });

  querySelector('#decrement').onClick.listen((_) {
    store.dispatch(AppAction.decrement);
  });

  querySelector('#incrementIfOdd').onClick.listen((_) {
    if (store.state.count % 2 != 0) store.dispatch(AppAction.increment);
  });

  querySelector('#incrementAsync').onClick.listen((_) {
    new Future.delayed(new Duration(milliseconds: 1000)).then((_) {
      store.dispatch(AppAction.increment);
    });
  });
}
