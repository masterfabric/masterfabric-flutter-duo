import 'package:flutter_test/flutter_test.dart';

import 'package:hello_flutter/main.dart';

void main() {
  testWidgets('renders MasterFabric hero', (tester) async {
    await tester.pumpWidget(const MasterFabricApp());
    expect(find.text('MasterFabric'), findsWidgets);
  });
}
