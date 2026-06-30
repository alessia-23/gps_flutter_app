enum LocationFailureType {
  permissionDenied,
  permissionDeniedForever,
  servicesDisabled,
  timeout,
  unknown
}

class LocationFailure {
  final LocationFailureType type;
  final String message;

  LocationFailure({
    required this.type,
    required this.message,
  });

  factory LocationFailure.permissionDenied() {
    return LocationFailure(
      type: LocationFailureType.permissionDenied,
      message: 'Permiso de ubicación denegado. Por favor, concede el permiso para usar la app.',
    );
  }

  factory LocationFailure.permissionDeniedForever() {
    return LocationFailure(
      type: LocationFailureType.permissionDeniedForever,
      message: 'Los permisos de ubicación están denegados permanentemente. Habilítalos desde los ajustes.',
    );
  }

  factory LocationFailure.servicesDisabled() {
    return LocationFailure(
      type: LocationFailureType.servicesDisabled,
      message: 'El servicio de ubicación (GPS) está desactivado.',
    );
  }

  factory LocationFailure.timeout() {
    return LocationFailure(
      type: LocationFailureType.timeout,
      message: 'Tiempo de espera agotado al intentar obtener la ubicación GPS.',
    );
  }

  factory LocationFailure.unknown([String? details]) {
    return LocationFailure(
      type: LocationFailureType.unknown,
      message: details ?? 'Ocurrió un error desconocido al obtener la ubicación.',
    );
  }

  @override
  String toString() => message;
}
