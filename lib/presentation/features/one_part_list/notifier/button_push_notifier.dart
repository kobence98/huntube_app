import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'button_push_notifier.g.dart';

@riverpod
class ButtonPushNotifier extends _$ButtonPushNotifier {
  @override
  int? build() {
    return null;
  }

  void buttonDown(int id) {
    state = id;
  }

  void buttonUp(int id) {
    state = null;
  }

}