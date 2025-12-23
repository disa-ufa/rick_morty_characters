import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsStore extends ChangeNotifier {
  SettingsStore(this._box);

  final Box _box;

  static const _keyIsDark = 'isDark';

  bool get isDark => (_box.get(_keyIsDark) as bool?) ?? false;

  void toggleTheme() {
    final newValue = !isDark;
    _box.put(_keyIsDark, newValue);
    notifyListeners();
  }
}
