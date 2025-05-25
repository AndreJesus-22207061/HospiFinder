import 'package:flutter/material.dart';
import 'package:prjectcm/screens/avaliacaoPage.dart';
import 'package:prjectcm/screens/dashboardPage.dart';
import 'package:prjectcm/screens/listaPage.dart';
import 'package:prjectcm/screens/mapaPage.dart';

final pages = [
  (title: 'Dashboard' ,icon: Icons.home_rounded ,widget: DashboardPage(), key : Key("dashboard-bottom-bar-item")),
  (title: 'Lista' ,icon: Icons.format_list_bulleted_rounded ,widget: ListaPage(), key : Key("lista-bottom-bar-item")),
  (title: 'Mapa' ,icon: Icons.map_rounded ,widget: MapaPage(), key : Key("mapa-bottom-bar-item")),
  (title: 'Avaliações' ,icon: Icons.star_rounded ,widget: AvaliacaoPage(), key : Key("avaliacoes-bottom-bar-item")),
];