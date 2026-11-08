import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huntube_app/core/providers/files_provider.dart';
import 'package:huntube_app/domain/models/part_files.dart';
import 'package:huntube_app/presentation/features/home/home_screen.dart';
import 'package:huntube_app/presentation/theme/app_theme.dart';
import 'package:huntube_app/presentation/widgets/app_info_dialog.dart';

void main() {
  testWidgets('privacy and support are available offline from the home app bar',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          readFilesProvider.overrideWith((ref) async => <PartFiles>[]),
        ],
        child: MaterialApp(theme: appTheme, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Segítség és adatvédelem'));
    await tester.pumpAndSettle();

    expect(find.byType(AppInfoDialog), findsOneWidget);
    expect(find.text('R.I.P TheJustMatthew'), findsOneWidget);
    expect(find.text('Adatkezelés'), findsOneWidget);
    expect(
        find.textContaining('nem továbbít használati vagy személyes adatokat'),
        findsOneWidget);
    expect(find.textContaining('biztonsági mentéseket külön'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text(AppInfoDialog.privacyUrl),
      150,
      scrollable: find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text(AppInfoDialog.supportEmail), findsOneWidget);
    expect(find.text(AppInfoDialog.supportUrl), findsOneWidget);
    expect(find.text(AppInfoDialog.privacyUrl), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Bezárás'));
    await tester.pumpAndSettle();
    expect(find.byType(AppInfoDialog), findsNothing);
  });
}
