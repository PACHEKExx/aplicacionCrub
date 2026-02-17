import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../modelos/contacto.dart';
import '../modelos/usuario.dart';

class BaseDatosApp {
  BaseDatosApp._();

  static final BaseDatosApp instancia = BaseDatosApp._();

  static const _nombreBd = 'agenda_contactos.db';
  Database? _bd;

  Future<Database> get bd async {
    if (_bd != null) {
      return _bd!;
    }
    _bd = await _inicializarBd();
    return _bd!;
  }

  Future<Database> _inicializarBd() async {
    final rutaBase = await getDatabasesPath();
    final rutaCompleta = p.join(rutaBase, _nombreBd);

    return openDatabase(
      rutaCompleta,
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL
          )
        ''');

        await database.execute('''
          CREATE TABLE contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            phone TEXT NOT NULL,
            email TEXT,
            company TEXT,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');

        await database.execute(
          'CREATE INDEX idx_contacts_user_name ON contacts(user_id, first_name, last_name)',
        );
      },
    );
  }

  String _hashClave(String clave) {
    final digest = sha256.convert(utf8.encode(clave));
    return digest.toString();
  }

  Future<Usuario?> registrarUsuario({
    required String nombreUsuario,
    required String clave,
  }) async {
    final database = await bd;
    final usuarioLimpio = nombreUsuario.trim();

    if (usuarioLimpio.isEmpty || clave.isEmpty) {
      return null;
    }

    final existente = await database.query(
      'users',
      where: 'LOWER(username) = LOWER(?)',
      whereArgs: [usuarioLimpio],
      limit: 1,
    );
    if (existente.isNotEmpty) {
      return null;
    }

    final id = await database.insert('users', <String, Object?>{
      'username': usuarioLimpio,
      'password_hash': _hashClave(clave),
    });

    return Usuario(id: id, nombreUsuario: usuarioLimpio);
  }

  Future<Usuario?> iniciarSesion({
    required String nombreUsuario,
    required String clave,
  }) async {
    final database = await bd;
    final usuarioLimpio = nombreUsuario.trim();

    if (usuarioLimpio.isEmpty || clave.isEmpty) {
      return null;
    }

    final filas = await database.query(
      'users',
      where: 'LOWER(username) = LOWER(?) AND password_hash = ?',
      whereArgs: [usuarioLimpio, _hashClave(clave)],
      limit: 1,
    );

    if (filas.isEmpty) {
      return null;
    }
    return Usuario.desdeMapa(filas.first);
  }

  Future<List<Contacto>> obtenerContactos({
    required int usuarioId,
    String busqueda = '',
  }) async {
    final database = await bd;
    final texto = busqueda.trim().toLowerCase();

    final clausulaWhere = texto.isEmpty
        ? 'user_id = ?'
        : 'user_id = ? AND ('
              'LOWER(first_name || " " || last_name) LIKE ? OR '
              'LOWER(first_name) LIKE ? OR '
              'LOWER(last_name) LIKE ?'
              ')';

    final argumentos = texto.isEmpty
        ? <Object?>[usuarioId]
        : <Object?>[
            usuarioId,
            '%$texto%',
            '%$texto%',
            '%$texto%',
          ];

    final filas = await database.query(
      'contacts',
      where: clausulaWhere,
      whereArgs: argumentos,
      orderBy: 'first_name COLLATE NOCASE, last_name COLLATE NOCASE',
    );

    return filas.map(Contacto.desdeMapa).toList();
  }

  Future<void> crearContacto(Contacto contacto) async {
    final database = await bd;
    await database.insert('contacts', contacto.aMapa());
  }

  Future<void> actualizarContacto(Contacto contacto) async {
    final database = await bd;
    await database.update(
      'contacts',
      contacto.aMapa(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [contacto.id, contacto.usuarioId],
    );
  }

  Future<void> eliminarContacto({
    required int idContacto,
    required int usuarioId,
  }) async {
    final database = await bd;
    await database.delete(
      'contacts',
      where: 'id = ? AND user_id = ?',
      whereArgs: [idContacto, usuarioId],
    );
  }
}
