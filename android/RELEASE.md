# Android release

The existing Play listing uses `com.justmatthew.TheJustMatthewApp`. Keep that
application ID when updating it. The displayed app name is `Simán Herri`.

Configure the existing upload keystore with ignored `android/key.properties`
(see `key.properties.example`), or provide `ANDROID_KEYSTORE_PATH`,
`ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, and `ANDROID_KEY_PASSWORD`.
Environment values take precedence. An absent signing configuration stops the
release build instead of falling back to the debug key. If the original upload
key is lost, register its replacement through Play Console before uploading.

```sh
flutter pub get
flutter test
flutter build appbundle --release
```

The project targets API 36 and uses NDK 28.2.13676358. Its Isar Community native
libraries support 16 kB pages. Model generation and database migration checks
are documented in `tool/isar_generator/README.md` and `test/fixtures/README.md`.
