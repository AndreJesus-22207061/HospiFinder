/*import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prjectcm/data/sns_repository.dart';
import 'package:prjectcm/main.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/widgets/hospitalBox.dart';
import 'package:provider/provider.dart';
import 'package:testable_form_field/testable_form_field.dart';


void main() {
  runWidgetTests();
}

void runWidgetTests() {
  final testHospitals = [
    Hospital(
      id: 10,
      name: 'Hospital da Lupitxula',
      latitude: 24.712821321414,
      longitude: -4.32300,
      address: 'Rua da Lupitxula',
      phoneNumber: 213452122,
      email: 'hospital_lupitxula@gmail.com',
      district: 'Lisbon',
      hasEmergency: true,
    ),
    Hospital(
      id: 11,
      name: 'Hospital Tralalero Tralala',
      latitude: 21.813,
      longitude: 1.102,
      address: 'Rua do Mateeeo',
      phoneNumber: 214234454,
      email: 'hospital_tralalero@email.pt',
      district: 'Lisboa',
      hasEmergency: false,
    ),
  ];


  testWidgets('Aceder a um hospital a partir da lista e verificar se este aparece nos ultimos acedidos do Dashboard', (WidgetTester tester) async {
    final snsRepository = SnsRepository();

    for (var hospital in testHospitals) {
      snsRepository.insertHospital(hospital);
    }

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<SnsRepository>.value(value: snsRepository),
      ],
      child: const MyApp(),
    ));


    await tester.pumpAndSettle(Duration(milliseconds: 200));

    var dashboardInicioBottomBarItemFinder = find.byKey(Key('dashboard-bottom-bar-item'));
    expect(dashboardInicioBottomBarItemFinder, findsOneWidget,
        reason: "Deveria existir um NavigationDestination com a key 'dashboard-bottom-bar-item'");
    await tester.tap(dashboardInicioBottomBarItemFinder);
    await tester.pumpAndSettle();

    var lastVisitedKeyFinder = find.byKey(Key('last-visited-key'));
    expect(lastVisitedKeyFinder, findsNothing,
        reason: "Ainda não pode existir a key 'last-visited-key' pois ainda nao foi acedido nenhum hospital");

    var listBottomBarItemFinder = find.byKey(Key('lista-bottom-bar-item'));
    expect(listBottomBarItemFinder, findsOneWidget,
        reason: "Deveria existir um NavigationDestination com a key 'lista-bottom-bar-item'");
    await tester.tap(listBottomBarItemFinder);
    await tester.pumpAndSettle();

    final Finder listViewFinder = find.byKey(Key('list-view'));
    expect(listViewFinder, findsOneWidget,
        reason: "Depois de saltar para o ecrã com a lista, deveria existir um ListView com a key 'list-view'");
    expect(tester.widget(listViewFinder), isA<ListView>(),
        reason: "O widget com a key 'list-view' deveria ser um ListView");

    final Finder listTilesFinder = find.descendant(of: listViewFinder, matching: find.byType(ListTile));
    final tiles = List.from(tester.widgetList<ListTile>(listTilesFinder));
    expect(tiles.length, 2, reason: "Deveriam existir 2 ListTiles dentro do ListView dos hospitais");


    final Finder firstTileTextFinder = find.descendant(of: listTilesFinder.first, matching: find.text("Hospital da Lupitxula"));
    expect(firstTileTextFinder, findsOneWidget,
        reason: "O primeiro ListTile deveria conter um Text com o texto 'Hospital da Lupitxula'");


    final Finder secondTileTextFinder = find.descendant(of: listTilesFinder.last, matching: find.text("Hospital Tralalero Tralala"));
    expect(secondTileTextFinder, findsOneWidget,
        reason: "O segundo ListTile deveria conter um Text com o texto 'Hospital Tralalero Tralala'");

    await tester.tap(listTilesFinder.first);
    await tester.pumpAndSettle();


    final Finder hospitalFinder = find.text('Hospital da Lupitxula');
    expect(hospitalFinder, findsAtLeastNWidgets(1),
        reason: "Deveria existir pelo menos um Text com o texto 'hospital 1' (primeiro elemento da lista)");
    expect(find.text('Com Urgência'), findsOneWidget,
        reason: "Deveria existir pelo menos um Text com o texto 'Com Urgência'");


    await tester.pageBack();
    await tester.pumpAndSettle();

    var dashboardBottomBarItemFinder = find.byKey(Key('dashboard-bottom-bar-item'));
    expect(dashboardBottomBarItemFinder, findsOneWidget,
        reason: "Deveria existir um NavigationDestination com a key 'dashboard-bottom-bar-item'");
    await tester.tap(dashboardBottomBarItemFinder);
    await tester.pumpAndSettle();

    final Finder lastVisitedListViewFinder = find.byKey(Key('last-visited-key'));
    expect(lastVisitedListViewFinder, findsOneWidget,
        reason: "Depois de saltar para o ecrã do dasboard, deveria existir um ListView com a key 'last-visited-key'");
    expect(tester.widget(lastVisitedListViewFinder), isA<ListView>(),
        reason: "O widget com a key 'last-visited-key' deveria ser um ListView");
  });


  testWidgets('Aceder a um hospital a partir da secção de Mais Próximos e verificar se aparece nos Últimos Acedidos ao voltar ao Dashboard', (WidgetTester tester) async {
    final snsRepository = SnsRepository();

    for (var hospital in testHospitals) {
      snsRepository.insertHospital(hospital);
    }

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<SnsRepository>.value(value: snsRepository),
      ],
      child: const MyApp(),
    ));


    await tester.pumpAndSettle(Duration(milliseconds: 200));



    var dashboardInicioBottomBarItemFinder = find.byKey(Key('dashboard-bottom-bar-item'));
    expect(dashboardInicioBottomBarItemFinder, findsOneWidget,
        reason: "Deveria existir um NavigationDestination com a key 'dashboard-bottom-bar-item'");
    await tester.tap(dashboardInicioBottomBarItemFinder);
    await tester.pumpAndSettle();

    // Verificar que nao existe ainda ultimos acedidos
    var lastVisitedKeyFinder = find.byKey(Key('last-visited-key'));
    expect(lastVisitedKeyFinder, findsNothing,
        reason: "Ainda não pode existir a key 'last-visited-key' pois ainda nao foi acedido nenhum hospital");


    //Verficar que tem de existir items na lista
    final listViewFinder = find.byKey(const Key('Nearest-hospítal-key'));
    expect(listViewFinder, findsOneWidget,
        reason: 'A lista de hospitais mais próximos deve estar presente.');

    expect(find.byType(HospitalBox), findsWidgets,
        reason: 'Devem existir HospitalBox visíveis na lista de hospitais mais próximos.');

    // Tap no primeiro hospital da lista "Mais Próximos"
    final firstHospitalBox = find.byType(HospitalBox).first;
    await tester.tap(firstHospitalBox);
    await tester.pumpAndSettle();

    // Simula o regresso ao dashboard (pop da página de detalhes)
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    // Verificar se agora aparece a secção dos "Últimos Acedidos"
    final lastVisitedFinder = find.byKey(Key('last-visited-key'));
    expect(lastVisitedFinder, findsOneWidget,
        reason: 'A secção dos últimos acedidos deve estar visível após visitar um hospital.');

    // Verificar que o hospital visitado está listado corretamente
    final visitedHospitalTextFinder = find.descendant(
        of: lastVisitedFinder, matching: find.text("Hospital Tralalero Tralala"));
    expect(visitedHospitalTextFinder, findsOneWidget,
        reason: "O hospital 'Hospital Tralalero Tralala' deveria aparecer nos últimos acedidos.");

  });

  testWidgets('Pesquisar por hospital e verificar resultado na lista', (WidgetTester tester) async {
    final snsRepository = SnsRepository();

    for (var hospital in testHospitals) {
      snsRepository.insertHospital(hospital);
    }

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<SnsRepository>.value(value: snsRepository),
      ],
      child: const MyApp(),
    ));


    await tester.pumpAndSettle(Duration(milliseconds: 200));

    // Tocar no botão de dashboard para garantir que está na página certa
    final dashboardItem = find.byKey(Key('dashboard-bottom-bar-item'));
    await tester.tap(dashboardItem);
    await tester.pumpAndSettle();

    // Encontrar e escrever na barra de pesquisa
    final searchField = find.byKey(Key('search-hospital-field'));
    expect(searchField, findsOneWidget, reason: "Deve existir um campo de pesquisa");
    await tester.enterText(searchField, 'Tralalero Tralala');
    await tester.pumpAndSettle();
    final listaResultados = find.byKey(Key('search-results-container'));
    expect(
      find.descendant(of: listaResultados, matching: find.byType(GestureDetector)),
      findsOneWidget,
    );

    expect(
      find.descendant(of: listaResultados, matching: find.text('Hospital Tralalero Tralala')),
      findsOneWidget,
    );
  });


  testWidgets('Mostrar erro se a data inserida for invalida', (WidgetTester tester) async {
    final snsRepository = SnsRepository();

    for (var hospital in testHospitals) {
      snsRepository.insertHospital(hospital);
    }

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<SnsRepository>.value(value: snsRepository),
      ],
      child: const MyApp(),
    ));

    await tester.pumpAndSettle(Duration(milliseconds: 200));

    // Navegar para a página de avaliação
    var avaliacoesBottomBarItemFinder = find.byKey(Key('avaliacoes-bottom-bar-item'));
    expect(avaliacoesBottomBarItemFinder, findsOneWidget,
        reason: "Deveria existir um NavigationDestination com a key 'avaliacoes-bottom-bar-item'");
    await tester.tap(avaliacoesBottomBarItemFinder);
    await tester.pumpAndSettle();

    final Finder hospitalSelectionViewFinder = find.byKey(Key('evaluation-hospital-selection-field'));
    expect(hospitalSelectionViewFinder, findsOneWidget,
        reason: "No ecrã do formulário, deveria existir um Widget com a key 'evaluation-hospital-selection-field'");
    expect(tester.widget(hospitalSelectionViewFinder), isA<TestableFormField<Hospital>>(),
        reason: "O widget com a key 'evaluation-hospital-selection-field' deveria ser um TestableFormField<Hospital>");
    TestableFormField<Hospital> hospitalSelectionFormField = tester.widget(hospitalSelectionViewFinder);


    final Finder ratingViewFinder = find.byKey(Key('evaluation-rating-field'));
    expect(ratingViewFinder, findsOneWidget,
        reason: "No ecrã do formulário, deveria existir um Widget com a key 'evaluation-rating-field'");
    expect(tester.widget(ratingViewFinder), isA<TestableFormField<int>>(),
        reason: "O widget com a key 'evaluation-rating-field' deveria ser um TestableFormField<int>");
    TestableFormField<int> ratingFormField = tester.widget(ratingViewFinder);

    final Finder dateTimeViewFinder = find.byKey(Key('evaluation-datetime-field'));
    expect(dateTimeViewFinder, findsOneWidget,
        reason: "No ecrã do formulário, deveria existir um Widget com a key 'evaluation-datetime-field'");
    expect(tester.widget(dateTimeViewFinder), isA<TestableFormField<DateTime>>(),
        reason: "O widget com a key 'evaluation-datetime-field' deveria ser um TestableFormField<DateTime>");

    final Finder commentViewFinder = find.byKey(Key('evaluation-comment-field'));
    expect(commentViewFinder, findsOneWidget,
        reason: "No ecrã do formulário, deveria existir um Widget com a key 'evaluation-comment-field'");
    expect(tester.widget(commentViewFinder), isA<TestableFormField<String>>(),
        reason: "O widget com a key 'evaluation-comment-field' deveria ser um TestableFormField<String>");
    TestableFormField<String> commentFormField = tester.widget(commentViewFinder);

    const dataInvalida = '31/02/2025 12:00';
    hospitalSelectionFormField.setValue(testHospitals[0]);
    ratingFormField.setValue(4);
    await tester.enterText(
      find.byKey(Key('evaluation-datetime-field')),
      dataInvalida,
    );
    commentFormField.setValue("Tudo ok.");


    final Finder submitButtonViewFinder = find.byKey(Key('evaluation-form-submit-button'));
    expect(submitButtonViewFinder, findsOneWidget,
        reason: "No ecrã do formulário, deveria existir um Widget com a key 'evaluation-form-submit-button'");
    await tester.tap(submitButtonViewFinder);
    await tester.pumpAndSettle();

    // it should show a text near the field explaining the error
    expect(find.textContaining('Preenche uma data e hora válidas'), findsOneWidget);

    // it should show a snackbar telling a field is missing
    expect(find.byType(SnackBar), findsOneWidget);
  });



  testWidgets('Insercao de 2 avaliacoes para o mesmo hospital e validacao da media', (WidgetTester tester) async {
    final snsRepository = SnsRepository();

    for (var hospital in testHospitals) {
      snsRepository.insertHospital(hospital);
    }

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<SnsRepository>.value(value: snsRepository),
      ],
      child: const MyApp(),
    ));


    // have to wait for async initializations
    await tester.pumpAndSettle(Duration(milliseconds: 200));

    var avaliacoesBottomBarItemFinder = find.byKey(Key('avaliacoes-bottom-bar-item'));
    expect(avaliacoesBottomBarItemFinder, findsOneWidget,
        reason: "Deveria existir um NavigationDestination com a key 'avaliacoes-bottom-bar-item'");
    await tester.tap(avaliacoesBottomBarItemFinder);
    await tester.pumpAndSettle();

    final Finder hospitalSelectionViewFinder = find.byKey(Key('evaluation-hospital-selection-field'));
    expect(hospitalSelectionViewFinder, findsOneWidget,
        reason: "No ecrã do formulário, deveria existir um Widget com a key 'evaluation-hospital-selection-field'");
    expect(tester.widget(hospitalSelectionViewFinder), isA<TestableFormField<Hospital>>(),
        reason: "O widget com a key 'evaluation-hospital-selection-field' deveria ser um TestableFormField<Hospital>");
    TestableFormField<Hospital> hospitalSelectionFormField = tester.widget(hospitalSelectionViewFinder);

    final Finder ratingViewFinder = find.byKey(Key('evaluation-rating-field'));
    expect(ratingViewFinder, findsOneWidget,
        reason: "No ecrã do formulário, deveria existir um Widget com a key 'evaluation-rating-field'");
    expect(tester.widget(ratingViewFinder), isA<TestableFormField<int>>(),
        reason: "O widget com a key 'evaluation-rating-field' deveria ser um TestableFormField<int>");
    TestableFormField<int> ratingFormField = tester.widget(ratingViewFinder);

    final Finder dateTimeViewFinder = find.byKey(Key('evaluation-datetime-field'));
    expect(dateTimeViewFinder, findsOneWidget,
        reason: "No ecrã do formulário, deveria existir um Widget com a key 'evaluation-datetime-field'");
    expect(tester.widget(dateTimeViewFinder), isA<TestableFormField<DateTime>>(),
        reason: "O widget com a key 'evaluation-datetime-field' deveria ser um TestableFormField<DateTime>");
    TestableFormField<DateTime> dateTimeFormField = tester.widget(dateTimeViewFinder);

    final Finder commentViewFinder = find.byKey(Key('evaluation-comment-field'));
    expect(commentViewFinder, findsOneWidget,
        reason: "No ecrã do formulário, deveria existir um Widget com a key 'evaluation-comment-field'");
    expect(tester.widget(commentViewFinder), isA<TestableFormField<String>>(),
        reason: "O widget com a key 'evaluation-comment-field' deveria ser um TestableFormField<String>");
    TestableFormField<String> commentFormField = tester.widget(commentViewFinder);

    // using "an hour ago" instead of current time since probably the form field will have its default value set to now
    final aHourAgo1 = DateTime.now().subtract(Duration(hours: 1));
    hospitalSelectionFormField.setValue(testHospitals[0]);
    ratingFormField.setValue(4);  // don't set the value for now
    dateTimeFormField.setValue(aHourAgo1);
    commentFormField.setValue("Tudo ok.");

    final Finder submitButtonViewFinder = find.byKey(Key('evaluation-form-submit-button'));
    expect(submitButtonViewFinder, findsOneWidget,
        reason: "No ecrã do formulário, deveria existir um Widget com a key 'evaluation-form-submit-button'");
    await tester.tap(submitButtonViewFinder);
    await tester.pumpAndSettle();


    final aHourAgo2 = DateTime.now().subtract(Duration(hours: 1));
    hospitalSelectionFormField.setValue(testHospitals[0]);
    ratingFormField.setValue(1);  // don't set the value for now
    dateTimeFormField.setValue(aHourAgo2);
    commentFormField.setValue("Não gostei nada.");

    await tester.tap(submitButtonViewFinder);
    await tester.pumpAndSettle();


    var listBottomBarItemFinder = find.byKey(Key('lista-bottom-bar-item'));
    expect(listBottomBarItemFinder, findsOneWidget);
    await tester.tap(listBottomBarItemFinder);
    await tester.pumpAndSettle();

    final Finder listViewFinder = find.byKey(Key('list-view'));
    expect(listViewFinder, findsOneWidget);
    final Finder listTilesFinder = find.descendant(of: listViewFinder, matching: find.byType(ListTile));
    final tiles = List.from(tester.widgetList<ListTile>(listTilesFinder));
    expect(tiles.length, 2);

    await tester.tap(listTilesFinder.first);
    await tester.pumpAndSettle();

    expect(find.text('Hospital da Lupitxula'), findsAtLeastNWidgets(1),
        reason: "Deveria existir pelo menos um Text com o texto 'Hospital da Lupitxula'");

    expect(find.text('2.5'), findsAtLeastNWidgets(1),
        reason: "Deveria existir pelo menos um Text com o texto '2.5' (media das avaliações)");


  });

}


*/

