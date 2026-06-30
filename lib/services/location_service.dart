import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../core/errors/location_failure.dart';

class LocationService {
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Request permissions and get current location.
  /// Throws [LocationFailure] on error.
  Future<Position> getCurrentLocation() async {
    try {
      // 1. Check if services are enabled
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        throw LocationFailure.servicesDisabled();
      }

      // 2. Check permissions
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationFailure.permissionDenied();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationFailure.permissionDeniedForever();
      }

      // 3. Get position with a timeout
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } on TimeoutException {
      throw LocationFailure.timeout();
    } on LocationFailure {
      rethrow;
    } catch (e) {
      throw LocationFailure.unknown(e.toString());
    }
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
