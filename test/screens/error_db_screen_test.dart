import 'package:flutter_test/flutter_test.dart';
import 'package:sidekick/src/screens/error_db_screen.dart';

void main() {
  testWidgets('shows the retry button and invokes onRetry when tapped',
      (tester) async {
    var attempts = 0;

    await tester.pumpWidget(
      ErrorDBScreen(
        onRetry: () async {
          attempts++;
        },
      ),
    );
    await tester.pump();

    final retryButton = find.text('Try Again');
    expect(retryButton, findsOneWidget);

    // The action row sits below the fold in the default test viewport
    await tester.ensureVisible(retryButton);
    await tester.pumpAndSettle();
    await tester.tap(retryButton, warnIfMissed: false);
    await tester.pump();

    expect(attempts, 1);
  });

  testWidgets('hides the retry button when no callback is given',
      (tester) async {
    await tester.pumpWidget(const ErrorDBScreen());
    await tester.pump();

    expect(find.text('Try Again'), findsNothing);
    expect(find.text('Close'), findsOneWidget);
  });
}
