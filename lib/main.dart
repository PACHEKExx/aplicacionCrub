import 'package:flutter/material.dart';

import 'modelos/usuario.dart';
import 'pantallas/pantalla_contactos.dart';
import 'pantallas/pantallaprincipal.dart';

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
    const esquema = ColorScheme.light(
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: Colors.black,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Colors.black,
      onError: Colors.white,
    );

    return MaterialApp(
      title: 'Agenda de Contactos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: esquema,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black54),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.black87),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.black,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
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
