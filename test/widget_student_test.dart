import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prjectcm/connectivity_module.dart';
import 'package:prjectcm/data/http_sns_datasource.dart';
import 'package:prjectcm/data/sns_repository.dart';
import 'package:prjectcm/data/sqflite_sns_datasource.dart';
import 'package:prjectcm/location_module.dart';
import 'package:prjectcm/main.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/widgets/hospitalBox.dart';
import 'package:provider/provider.dart';
import 'package:testable_form_field/testable_form_field.dart';

import 'fake_connectivity_module.dart';
import 'fake_http_sns_datasource.dart';
import 'fake_location_module.dart';
import 'fake_sqflite_sns_datasource.dart';


void main() {
  runWidgetTests();
}

void runWidgetTests() {


  testWidgets('Mostrar erro caso nao seja escolhido um hospital', (WidgetTester tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<HttpSnsDataSource>.value(value: FakeHttpSnsDataSource()),
        Provider<SqfliteSnsDataSource>.value(value: FakeSqfliteSnsDataSource()),
        Provider<LocationModule>.value(value: FakeLocationModule()),
        Provider<ConnectivityModule>.value(value: FakeConnectivityModule()),
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

    const dataInvalida = '31/03/2025 12:00';
    ratingFormField.setValue(5);
    await tester.enterText(
      find.byKey(Key('evaluation-datetime-field')),
      dataInvalida,
    );
    commentFormField.setValue("Ótimo.");


    final Finder submitButtonViewFinder = find.byKey(Key('evaluation-form-submit-button'));
    expect(submitButtonViewFinder, findsOneWidget,
        reason: "No ecrã do formulário, deveria existir um Widget com a key 'evaluation-form-submit-button'");
    await tester.tap(submitButtonViewFinder);
    await tester.pumpAndSettle();

    // it should show a text near the field explaining the error
    expect(find.textContaining('Escolha um hospital'), findsOneWidget);

    // it should show a snackbar telling a field is missing
    expect(find.byType(SnackBar), findsOneWidget);
  });


  testWidgets('Mostrar erro se a data inserida for invalida', (WidgetTester tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<HttpSnsDataSource>.value(value: FakeHttpSnsDataSource()),
        Provider<SqfliteSnsDataSource>.value(value: FakeSqfliteSnsDataSource()),
        Provider<LocationModule>.value(value: FakeLocationModule()),
        Provider<ConnectivityModule>.value(value: FakeConnectivityModule()),
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
    hospitalSelectionFormField.setValue(FakeHttpSnsDataSource().hospitals[0]);
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


  testWidgets('Mostrar erro se nao for preenchido o campo de rating', (WidgetTester tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<HttpSnsDataSource>.value(value: FakeHttpSnsDataSource()),
        Provider<SqfliteSnsDataSource>.value(value: FakeSqfliteSnsDataSource()),
        Provider<LocationModule>.value(value: FakeLocationModule()),
        Provider<ConnectivityModule>.value(value: FakeConnectivityModule()),
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

    const dataInvalida = '31/01/2025 12:00';
    hospitalSelectionFormField.setValue(FakeHttpSnsDataSource().hospitals[0]);
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
    expect(find.textContaining('Preencha a avaliação'), findsOneWidget);

    // it should show a snackbar telling a field is missing
    expect(find.byType(SnackBar), findsOneWidget);
  });




  testWidgets('Pesquisar por hospital e verificar resultado na lista', (WidgetTester tester) async {

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<HttpSnsDataSource>.value(value: FakeHttpSnsDataSource()),
        Provider<SqfliteSnsDataSource>.value(value: FakeSqfliteSnsDataSource()),
        Provider<LocationModule>.value(value: FakeLocationModule()),
        Provider<ConnectivityModule>.value(value: FakeConnectivityModule()),
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
    await tester.enterText(searchField, 'hospital 2');
    await tester.pumpAndSettle();

    final nomeHospital = FakeHttpSnsDataSource().hospitals[1].name;
    expect(find.text(nomeHospital), findsOneWidget);

  });



  testWidgets('Aceder a lista e clicar no filtro de urgencia ativa', (WidgetTester tester) async {

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<HttpSnsDataSource>.value(value: FakeHttpSnsDataSource()),
        Provider<SqfliteSnsDataSource>.value(value: FakeSqfliteSnsDataSource()),
        Provider<LocationModule>.value(value: FakeLocationModule()),
        Provider<ConnectivityModule>.value(value: FakeConnectivityModule()),
      ],
      child: const MyApp(),
    ));


    await tester.pumpAndSettle(Duration(milliseconds: 200));

    // Tocar no botão de dashboard para garantir que está na página certa
    final listItem = find.byKey(Key('lista-bottom-bar-item'));
    await tester.tap(listItem);
    await tester.pumpAndSettle();

    final Finder listViewFinder = find.byKey(Key('list-view'));
    expect(listViewFinder, findsOneWidget);
    final Finder listTilesFinder = find.descendant(of: listViewFinder, matching: find.byType(ListTile));
    final tiles = List.from(tester.widgetList<ListTile>(listTilesFinder));
    expect(tiles.length, 2);


    // Encontrar e escrever na barra de pesquisa
    final buttonField = find.byKey(Key('urgencia-button'));
    expect(buttonField, findsOneWidget, reason: "Deve existir um botao de urgencia ativa");
    await tester.tap(buttonField);
    await tester.pumpAndSettle();

    final tiles1 = List.from(tester.widgetList<ListTile>(listTilesFinder));
    expect(tiles1.length, 1);

    final nomeHospital = FakeHttpSnsDataSource().hospitals[0].name;
    expect(find.text(nomeHospital), findsOneWidget);

  });



  testWidgets('Insercao de 2 avaliacoes para o mesmo hospital e validacao da media', (WidgetTester tester) async {

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<HttpSnsDataSource>.value(value: FakeHttpSnsDataSource()),
        Provider<SqfliteSnsDataSource>.value(value: FakeSqfliteSnsDataSource()),
        Provider<LocationModule>.value(value: FakeLocationModule()),
        Provider<ConnectivityModule>.value(value: FakeConnectivityModule()),
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
    hospitalSelectionFormField.setValue(FakeHttpSnsDataSource().hospitals[0]);
    ratingFormField.setValue(4);  // don't set the value for now
    dateTimeFormField.setValue(aHourAgo1);
    commentFormField.setValue("Tudo ok.");

    final Finder submitButtonViewFinder = find.byKey(Key('evaluation-form-submit-button'));
    expect(submitButtonViewFinder, findsOneWidget,
        reason: "No ecrã do formulário, deveria existir um Widget com a key 'evaluation-form-submit-button'");
    await tester.tap(submitButtonViewFinder);
    await tester.pumpAndSettle();


    final aHourAgo2 = DateTime.now().subtract(Duration(hours: 1));
    hospitalSelectionFormField.setValue(FakeHttpSnsDataSource().hospitals[0]);
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

    expect(find.text(FakeHttpSnsDataSource().hospitals[0].name), findsAtLeastNWidgets(1),
        reason: "Deveria existir pelo menos um Text com o texto 'hospital 1'");

    expect(find.text('2.5'), findsAtLeastNWidgets(1),
        reason: "Deveria existir pelo menos um Text com o texto '2.5' (media das avaliações)");


  });




}
  /*

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



*/

