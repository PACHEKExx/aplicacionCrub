import 'package:flutter/material.dart';

import '../modelos/contacto.dart';

class FormularioContacto extends StatefulWidget {
  const FormularioContacto({
    super.key,
    required this.usuarioId,
    this.contactoInicial,
  });

  final int usuarioId;
  final Contacto? contactoInicial;

  @override
  State<FormularioContacto> createState() => _FormularioContactoState();
}

class _FormularioContactoState extends State<FormularioContacto> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombresController;
  late final TextEditingController _apellidosController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _emailController;
  late final TextEditingController _empresaController;

  bool get _esEdicion => widget.contactoInicial != null;

  @override
  void initState() {
    super.initState();
    _nombresController =
        TextEditingController(text: widget.contactoInicial?.nombres ?? '');
    _apellidosController =
        TextEditingController(text: widget.contactoInicial?.apellidos ?? '');
    _telefonoController =
        TextEditingController(text: widget.contactoInicial?.telefono ?? '');
    _emailController =
        TextEditingController(text: widget.contactoInicial?.email ?? '');
    _empresaController =
        TextEditingController(text: widget.contactoInicial?.empresa ?? '');
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _empresaController.dispose();
    super.dispose();
  }

  void _guardarContacto() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final contacto = Contacto(
      id: widget.contactoInicial?.id,
      usuarioId: widget.usuarioId,
      nombres: _nombresController.text.trim(),
      apellidos: _apellidosController.text.trim(),
      telefono: _telefonoController.text.trim(),
      email: _emailController.text.trim(),
      empresa: _empresaController.text.trim(),
    );

    Navigator.of(context).pop(contacto);
  }

  String? _validarRequerido(String? valor, String etiqueta) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa $etiqueta';
    }
    return null;
  }

  String? _validarTelefono(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) {
      return 'Ingresa telefono';
    }
    final patronTelefono = RegExp(r'^[0-9+\-()\s]{7,20}$');
    if (!patronTelefono.hasMatch(texto)) {
      return 'Telefono invalido';
    }
    return null;
  }

  String? _validarEmail(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) {
      return null;
    }
    final patronEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!patronEmail.hasMatch(texto)) {
      return 'Email invalido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar contacto' : 'Nuevo contacto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombresController,
                decoration: const InputDecoration(
                  labelText: 'Nombres',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) => _validarRequerido(valor, 'nombres'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _apellidosController,
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) => _validarRequerido(valor, 'apellidos'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Numero telefonico',
                  border: OutlineInputBorder(),
                ),
                validator: _validarTelefono,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: _validarEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _empresaController,
                decoration: const InputDecoration(
                  labelText: 'Empresa o institucion',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _guardarContacto,
                  icon: const Icon(Icons.save),
                  label: Text(_esEdicion ? 'Guardar cambios' : 'Crear contacto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
