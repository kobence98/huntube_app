import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'elevated_button_notifier.g.dart';

@riverpod
class ElevatedButtonNotifier extends _$ElevatedButtonNotifier {
  @override
  Key? build() {
    return null;
  }

  void buttonDown(Key key) {
    state = key;
  }

  void buttonUp(Key key) {
    state = null;
  }

}