import 'package:flutter_test/flutter_test.dart';
import 'package:tucu_free_tacc/main.dart';

void main() {
  testWidgets('Carga inicial de la app', (WidgetTester tester) async {
    // Construye nuestra app
    await tester.pumpWidget(const TucuFreeTaccApp());

    // Verifica que la pantalla inicial sea la de Explorar
    expect(find.text('Pantalla: Explorar (Mapa)'), findsOneWidget);
  });
}
