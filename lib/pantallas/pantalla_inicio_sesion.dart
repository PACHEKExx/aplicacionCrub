import 'package:flutter/material.dart';

import '../datos/base_datos_app.dart';
import '../modelos/usuario.dart';
import 'pantalla_registro_usuario.dart';

class PantallaInicioSesion extends StatefulWidget {
  const PantallaInicioSesion({
    super.key,
    required this.alIniciarSesion,
  });

  final ValueChanged<Usuario> alIniciarSesion;

  @override
  State<PantallaInicioSesion> createState() => _PantallaInicioSesionState();
}

class _PantallaInicioSesionState extends State<PantallaInicioSesion> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _claveController = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _usuarioController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    final usuario = await BaseDatosApp.instancia.iniciarSesion(
      nombreUsuario: _usuarioController.text,
      clave: _claveController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _cargando = false;
    });

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales invalidas')),
      );
      return;
    }

    widget.alIniciarSesion(usuario);
  }

  Future<void> _abrirRegistro() async {
    final usuarioCreado = await Navigator.of(context).push<Usuario>(
      MaterialPageRoute(builder: (_) => const PantallaRegistroUsuario()),
    );

    if (!mounted || usuarioCreado == null) {
      return;
    }

    widget.alIniciarSesion(usuarioCreado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesion')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _usuarioController,
                        decoration: const InputDecoration(
                          labelText: 'Usuario',
                          prefixIcon: Icon(Icons.person),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (valor) {
                          if (valor == null || valor.trim().isEmpty) {
                            return 'Ingresa tu usuario';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _claveController,
                        decoration: const InputDecoration(
                          labelText: 'Contrasena',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        onFieldSubmitted: (_) => _ingresar(),
                        validator: (valor) {
                          if (valor == null || valor.isEmpty) {
                            return 'Ingresa tu contrasena';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _cargando ? null : _ingresar,
                          child: _cargando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Entrar'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _cargando ? null : _abrirRegistro,
                        child: const Text('Crear usuario'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
