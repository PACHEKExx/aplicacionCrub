class Usuario {
  const Usuario({
    required this.id,
    required this.nombreUsuario,
  });

  final int id;
  final String nombreUsuario;

  factory Usuario.desdeMapa(Map<String, Object?> mapa) {
    return Usuario(
      id: mapa['id'] as int,
      nombreUsuario: mapa['username'] as String,
    );
  }
}
