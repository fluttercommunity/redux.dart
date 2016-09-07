#!/bin/sh
dart_files=$(git ls-tree --name-only --full-tree -r HEAD | grep '.dart$')
[ -z "$dart_files" ] && exit 0

unformatted=$(dartfmt -n $dart_files)
[ -z "$unformatted" ] && exit 0

# Some files are not dartfmt'd. Print message and fail.
for fn in $unformatted; do
  dartfmt -w $PWD/$fn
done

exit 1
