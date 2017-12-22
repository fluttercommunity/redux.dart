import 'dart:async';
import 'dart:html';

import 'package:redux/redux.dart';

void render(AppState state) {
  querySelector('#value').innerHtml = '${state.count}';
  querySelector('#clickValue').innerHtml = '${state.clickCount}';
}

class AppState {
  final int count;
  final int clickCount;

  AppState(this.count, this.clickCount);
}

enum AppAction { increment, decrement }

// Create a Reducer. A reducer is a pure function that takes the
// current State (int) and the Action that was dispatched. It should
// combine the two into a new state without mutating the state passed
// in! After the state is updated, the store will emit the update to
// the `onChange` stream.
//
// Because reducers are pure functions, they should not perform any
// side-effects, such as making an HTTP request or logging messages
// to a console. For that, use Middleware.
AppState counterReducer(AppState state, dynamic action) {
  if (action == AppAction.increment) {
    return new AppState(state.count + 1, state.clickCount);
  }
  if (action == AppAction.decrement) {
    return new AppState(state.count - 1, state.clickCount);
  }

  return state;
}

// Create a Reducer with a State (int) and an Action (String) Any dart object
// can be used for Action and State.
AppState clickCounterReducer(AppState state, dynamic action) {
  if (action == AppAction.increment) {
    return new AppState(state.count, state.clickCount + 1);
  }
  if (action == AppAction.decrement) {
    return new AppState(state.count, state.clickCount + 1);
  }

  return state;
}

void main() {
  // Create a new reducer and store for the app.
  final combined = combineReducers<AppState>([
    counterReducer,
    clickCounterReducer,
  ]);
  final store = new Store<AppState>(
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
    if (store.state.count % 2 != 0) {
      store.dispatch(AppAction.increment);
    }
  });

  querySelector('#incrementAsync').onClick.listen((_) {
    new Future<Null>.delayed(new Duration(milliseconds: 1000)).then((_) {
      store.dispatch(AppAction.increment);
    });
  });
}
