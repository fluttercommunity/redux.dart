# 2.0.0

  * *Breaking API Changes:*
    * `Reducer` is now a `typedef`. Use `ReducerClass<State>` if you'd like to continue to use a class interface.
    * `Middleware` is now a `typedef`. Use `MiddlewareClass<State>` as a replacement for the old `Middleware<State, Action>`
    * A `teardown` method has been added. Use it to shut down the store in the middle of your application lifecycle if you no longer need the store.
  * Added more docs
