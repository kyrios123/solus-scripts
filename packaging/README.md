# Solus packaging doc & utilities

## .arc-solus.bash
Extends the [arcanist](https://secure.phabricator.com/book/phabricator/article/arcanist/) `arc` command to add extra checks for Solus packagers (limited to `arc diff` at the moment).

Read the heading comment in the source for instructions.

### Release number
Warns if local package release number is not incremented by one compared to the package release number on the server

### Active diff
Warns if there is already on active differential for the current repository
