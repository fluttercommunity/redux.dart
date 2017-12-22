import 'dart:async';
import 'dart:html';

import 'package:redux/redux.dart';

void render(int state) {
  querySelector('#value').innerHtml = '$state';
}

enum Actions { increment, decrement }

// Create a Reducer. A reducer is a pure function that takes the
// current State (int) and the Action that was dispatched. It should
// combine the two into a new state without mutating the state passed
// in! After the state is updated, the store will emit the update to
// the `onChange` stream.
//
// Because reducers are pure functions, they should not perform any
// side-effects, such as making an HTTP request or logging messages
// to a console. For that, use Middleware.
int counterReducer(int state, dynamic action) {
  if (action == Actions.increment) {
    return state + 1;
  } else if (action == Actions.decrement) {
    return state - 1;
  }

  return state;
}

void main() {
  // Create a new reducer and store for the app.
  final store = new Store(counterReducer, initialState: 0);

  render(store.state);
  store.onChange.listen(render);

  querySelector('#increment').onClick.listen((_) {
    store.dispatch(Actions.increment);
  });

  querySelector('#decrement').onClick.listen((_) {
    store.dispatch(Actions.decrement);
  });

  querySelector('#incrementIfOdd').onClick.listen((_) {
    if (store.state % 2 != 0) {
      store.dispatch(Actions.increment);
    }
  });

  querySelector('#incrementAsync').onClick.listen((_) {
    new Future<Null>.delayed(new Duration(milliseconds: 1000)).then((_) {
      store.dispatch(Actions.increment);
    });
  });
}
