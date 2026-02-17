import 'package:flutter/material.dart';

import '../basededatos/db.dart';
import '../modelos/contacto.dart';
import '../modelos/usuario.dart';
import 'formularioC.dart';

class PantallaContactos extends StatefulWidget {
  const PantallaContactos({
    super.key,
    required this.usuario,
    required this.alCerrarSesion,
  });

  final Usuario usuario;
  final VoidCallback alCerrarSesion;

  @override
  State<PantallaContactos> createState() => _PantallaContactosState();
}

class _PantallaContactosState extends State<PantallaContactos> {
  final _busquedaController = TextEditingController();
  List<Contacto> _listaContactos = const [];
  String _textoBusqueda = '';
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarContactos();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cargarContactos() async {
    final busquedaActual = _textoBusqueda;
    if (_listaContactos.isEmpty) {
      setState(() {
        _cargando = true;
      });
    }

    final contactos = await BaseDatosApp.instancia.obtenerContactos(
      usuarioId: widget.usuario.id,
      busqueda: busquedaActual,
    );

    if (!mounted || busquedaActual != _textoBusqueda) {
      return;
    }

    setState(() {
      _listaContactos = contactos;
      _cargando = false;
    });
  }

  Future<void> _crearContacto() async {
    final nuevoContacto = await Navigator.of(context).push<Contacto>(
      MaterialPageRoute(
        builder: (_) => FormularioContacto(usuarioId: widget.usuario.id),
      ),
    );

    if (nuevoContacto == null) {
      return;
    }

    await BaseDatosApp.instancia.crearContacto(nuevoContacto);
    _cargarContactos();
  }

  Future<void> _editarContacto(Contacto contacto) async {
    final contactoEditado = await Navigator.of(context).push<Contacto>(
      MaterialPageRoute(
        builder: (_) => FormularioContacto(
          usuarioId: widget.usuario.id,
          contactoInicial: contacto,
        ),
      ),
    );

    if (contactoEditado == null) {
      return;
    }

    await BaseDatosApp.instancia.actualizarContacto(contactoEditado);
    _cargarContactos();
  }

  Future<void> _eliminarContacto(Contacto contacto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contexto) {
        return AlertDialog(
          title: const Text('Eliminar contacto'),
          content: Text('Se eliminara a ${contacto.nombreCompleto}. Continuar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(contexto).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(contexto).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    await BaseDatosApp.instancia.eliminarContacto(
      idContacto: contacto.id!,
      usuarioId: widget.usuario.id,
    );
    _cargarContactos();
  }

  Widget _construirListaContactos() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_listaContactos.isEmpty) {
      return const Center(
        child: Text('No hay contactos'),
      );
    }

    return ListView.separated(
      itemCount: _listaContactos.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final contacto = _listaContactos[index];
        final detalle = [
          'Tel: ${contacto.telefono}',
          contacto.email.isEmpty ? 'Email: -' : 'Email: ${contacto.email}',
          contacto.empresa.isEmpty
              ? 'Empresa: -'
              : 'Empresa: ${contacto.empresa}',
        ].join('\n');

        return ListTile(
          title: Text(contacto.nombreCompleto),
          subtitle: Text(detalle),
          isThreeLine: true,
          onTap: () => _editarContacto(contacto),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(Icons.edit),
                onPressed: () => _editarContacto(contacto),
              ),
              IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete),
                onPressed: () => _eliminarContacto(contacto),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contactos de ${widget.usuario.nombreUsuario}'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesion',
            onPressed: widget.alCerrarSesion,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _busquedaController,
              onChanged: (valor) {
                setState(() {
                  _textoBusqueda = valor;
                });
                _cargarContactos();
              },
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre o apellido',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(child: _construirListaContactos()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearContacto,
        child: const Icon(Icons.add),
      ),
    );
  }
}
