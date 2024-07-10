import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filter_favourites_notifier.g.dart';

@riverpod
class FilterFavouritesNotifier extends _$FilterFavouritesNotifier {
  @override
  bool build() {
    return false;
  }

  void filterOn() {
    state = true;
  }

  void filterOff() {
    state = false;
  }

}
