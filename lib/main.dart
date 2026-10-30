import 'package:flutter/widgets.dart';
import 'package:hello_flutter/app/app.dart';
import 'package:hello_flutter/app/core/di/injection.dart';
import 'package:hello_flutter/app/helper/layout/duo/duo_bridge.dart';

/// Boots DI and the iPhone Duo bridge, then runs [MasterFabricApp].
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  getIt<DuoBridge>().start();
  runApp(const MasterFabricApp());
}
