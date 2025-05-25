import 'package:flutter/material.dart';


class MapaPage extends StatefulWidget {
  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Text("Mapa",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
    );
  }
}