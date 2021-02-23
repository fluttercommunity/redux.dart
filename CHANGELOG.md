5.0.0-nullsafety

  * Update to null safety
  * Drop package:coverage
  * Remove web examples.  They depend on build_runner which has not been
    upgraded to null safety yet.

# 4.0.0+3

  * Update README

# 4.0.0+2

  * Update README with fluttercommunity links

# 4.0.0+1

  * Moved package to Flutter Community

# 4.0.0

  * `dispatch` returns the provided action 
  * Removed Dart 1.x support
  * Enforce Pedantic package lint rules
  * Enforce `public_member_api_docs` lint rule and add docs to missing parts
  * Update `travis.yml` with support for dartfmt, analysis, and code coverage
  * Add coverage badge to root README
  * Pub.dev updates
    * Longer description
    * https for package url
    * update example folder to include README

# 3.0.1

  * Update README based on feedback

# 3.0.0

  * Dart 2 support
  * Remove `ReducerBinding`, use `TypedReducer` 
  * Remove `combineTypedReducer`. Use `combineReducers` with normal reducers & `TypedReducer`s.
  * Remove `MiddlewareBinding`, use `TypedMiddleware`.
  * Remove `combineTypedMiddleware` -- no longer needed! Just create a normal `List<Middleware<State>>`!

# 2.1.1

  * Ensure the repo is 100% healthy. 

# 2.1.0

  * Add the `distinct` option. If set to true, the Store will not emit onChange events if the new State that is returned from your [reducer] in response to an Action is equal to the previous state. False by default.

# 2.0.4

  * Use absolute urls to fix broken links in documentation on Pub.

# 2.0.3

  * Add MOAR documentation

# 2.0.2

  * Add type-safe `combineTypedReducers` and `combineTypedMiddleware` functions

# 2.0.1

  * Add documentation highlighting the redux ecosystem

# 2.0.0

  * *Breaking API Changes:*
    * `Reducer` is now a `typedef`. Use `ReducerClass<State>` if you'd like to
      continue to use a class interface.
    * `Middleware` is now a `typedef`. Use `MiddlewareClass<State>` as a
      replacement for the old `Middleware<State, Action>`
    * A `teardown` method has been added. Use it to shut down the store in the
      middle of your application lifecycle if you no longer need the store.
  * Added more docs
