import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progress_bar_notifier.g.dart';

@riverpod
class ProgressBarNotifier extends _$ProgressBarNotifier {
  @override
  int? build() {
    return null;
  }

  void setActiveBar(int id) {
    state = id;
  }

  void reset() {
    state = null;
  }
}