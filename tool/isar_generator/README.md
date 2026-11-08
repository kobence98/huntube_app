# Isar model generation

Run from the repository root:

```sh
dart run tool/isar_generator/generate.dart
```

This isolated generator uses the current Isar Community toolchain without
forcing an unrelated Riverpod or AutoRoute migration. It stages the existing
`CachedLike` model, runs the official generator, and updates its generated part
in the application. Commit this tool's lockfile together with dependency changes.

Keep the collection name, ID field and database directory unchanged so that
existing favourites remain accessible. The regression test opens a database
created with the original Isar 3.1.0+1 implementation.
