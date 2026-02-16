import 'package:flutter/material.dart';

import 'modelos/usuario.dart';
import 'pantallas/pantalla_contactos.dart';
import 'pantallas/pantalla_inicio_sesion.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppContactos());
}

class AppContactos extends StatefulWidget {
  const AppContactos({super.key});

  @override
  State<AppContactos> createState() => _AppContactosState();
}

class _AppContactosState extends State<AppContactos> {
  Usuario? _usuarioActual;

  void _iniciarSesion(Usuario usuario) {
    setState(() {
      _usuarioActual = usuario;
    });
  }

  void _cerrarSesion() {
    setState(() {
      _usuarioActual = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda de Contactos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: _usuarioActual == null
          ? PantallaInicioSesion(alIniciarSesion: _iniciarSesion)
          : PantallaContactos(
              usuario: _usuarioActual!,
              alCerrarSesion: _cerrarSesion,
            ),
    );
  }
}
