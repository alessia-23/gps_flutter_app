import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/errors/location_failure.dart';
import '../../data/datasources/local_location_datasource.dart';
import '../../data/models/location_history_item.dart';
import '../../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final LocalLocationDataSource _dataSource = LocalLocationDataSource();

  Position? _currentPosition;
  String? _currentTime;
  bool _isLoading = false;
  LocationFailure? _failure;
  List<LocationHistoryItem> _history = [];

  Position? get currentPosition => _currentPosition;
  String? get currentTime => _currentTime;
  bool get isLoading => _isLoading;
  LocationFailure? get failure => _failure;
  List<LocationHistoryItem> get history => _history;

  static const String _permissionRequestedKey = 'location_permission_requested_before';

  /// Initialization
  Future<void> init() async {
    await loadHistory();
    await checkAndRequestPermissionOnStart();
  }

  /// Load location history from SharedPreferences
  Future<void> loadHistory() async {
    try {
      _history = await _dataSource.getHistory();
      notifyListeners();
    } catch (e) {
      _failure = LocationFailure.unknown('Error al cargar el historial: $e');
      notifyListeners();
    }
  }

  /// Automatically request permission only on the first run.
  /// If already granted, fetch location automatically.
  Future<void> checkAndRequestPermissionOnStart() async {
    final prefs = await SharedPreferences.getInstance();
    final bool requestedBefore = prefs.getBool(_permissionRequestedKey) ?? false;
    
    final permission = await _locationService.checkPermission();
    
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      // Permission already granted, fetch location automatically
      await fetchLocation(silent: true);
    } else if (permission == LocationPermission.denied && !requestedBefore) {
      // Request permission automatically for the first time
      await prefs.setBool(_permissionRequestedKey, true);
      await fetchLocation(silent: true);
    } else {
      // Permission denied before or deniedForever, don't request automatically
      // Just update status to alert user on UI (but don't set failure if we just started quietly)
    }
  }

  /// Fetch the current location and update state/history
  Future<void> fetchLocation({bool silent = false}) async {
    _isLoading = true;
    _failure = null;
    if (!silent) notifyListeners();

    try {
      final position = await _locationService.getCurrentLocation();
      _currentPosition = position;
      
      final now = DateTime.now();
      _currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      // Create history item
      final historyItem = LocationHistoryItem(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        time: _currentTime!,
      );

      // Save to SharedPreferences
      await _dataSource.addLocation(historyItem);
      
      // Reload history list
      _history = await _dataSource.getHistory();
    } on LocationFailure catch (f) {
      _failure = f;
    } catch (e) {
      _failure = LocationFailure.unknown(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all location history
  Future<void> clearHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dataSource.clearHistory();
      _history = [];
      _failure = null;
    } catch (e) {
      _failure = LocationFailure.unknown('Error al borrar el historial: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Opens native Android settings (App Settings or GPS Settings) depending on the error
  Future<void> openAppropriateSettings() async {
    if (_failure?.type == LocationFailureType.permissionDeniedForever) {
      await _locationService.openAppSettings();
    } else {
      await _locationService.openLocationSettings();
    }
  }
}
