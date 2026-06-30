import 'dart:convert';

class LocationHistoryItem {
  final double latitude;
  final double longitude;
  final double accuracy;
  final String time;

  LocationHistoryItem({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'time': time,
    };
  }

  factory LocationHistoryItem.fromMap(Map<String, dynamic> map) {
    return LocationHistoryItem(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      accuracy: (map['accuracy'] as num).toDouble(),
      time: map['time'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory LocationHistoryItem.fromJson(String source) =>
      LocationHistoryItem.fromMap(json.decode(source) as Map<String, dynamic>);
}
