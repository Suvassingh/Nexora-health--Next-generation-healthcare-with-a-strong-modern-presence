import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  static final AppSettings _instance = AppSettings._();
  factory AppSettings() => _instance;
  AppSettings._();

  bool _lowDataMode = false;

  bool get lowDataMode => _lowDataMode;

  void setLowDataMode(bool value) {
    if (_lowDataMode == value) return;
    _lowDataMode = value;
    notifyListeners();
  }

  static AppSettings of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<_AppSettingsInherited>();
    if (provider == null) {
      throw FlutterError(
        'No AppSettingsProvider found. Wrap your MaterialApp with AppSettingsProvider.',
      );
    }

    return provider.notifier!;
  }
}

class _AppSettingsInherited extends InheritedNotifier<AppSettings> {
  const _AppSettingsInherited({
    required AppSettings settings,
    required super.child,
  }) : super(notifier: settings);

  @override
  bool updateShouldNotify(_AppSettingsInherited old) =>
      old.notifier != notifier;
}

class AppSettingsProvider extends StatelessWidget {
  final Widget child;
  const AppSettingsProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return _AppSettingsInherited(settings: AppSettings(), child: child);
  }
}
