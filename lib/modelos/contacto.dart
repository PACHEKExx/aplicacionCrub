class Contacto {
  const Contacto({
    this.id,
    required this.usuarioId,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.email,
    required this.empresa,
  });

  final int? id;
  final int usuarioId;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String email;
  final String empresa;

  String get nombreCompleto => '$nombres $apellidos'.trim();

  Map<String, Object?> aMapa() {
    return <String, Object?>{
      'id': id,
      'user_id': usuarioId,
      'first_name': nombres,
      'last_name': apellidos,
      'phone': telefono,
      'email': email,
      'company': empresa,
    };
  }

  factory Contacto.desdeMapa(Map<String, Object?> mapa) {
    return Contacto(
      id: mapa['id'] as int,
      usuarioId: mapa['user_id'] as int,
      nombres: mapa['first_name'] as String,
      apellidos: mapa['last_name'] as String,
      telefono: mapa['phone'] as String,
      email: (mapa['email'] as String?) ?? '',
      empresa: (mapa['company'] as String?) ?? '',
    );
  }
}
