class RadioStation {
  final String stationuuid;
  final String name;
  final String urlResolved;
  final String favicon;
  final String tags;
  final String country;
  final int? bitrate;
  bool isFavorite;

  RadioStation({
    required this.stationuuid,
    required this.name,
    required this.urlResolved,
    required this.favicon,
    required this.tags,
    required this.country,
    this.bitrate,
    this.isFavorite = false,
  });

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      stationuuid: json['stationuuid'] ?? '',
      name: json['name'] ?? 'Unknown',
      urlResolved: json['url_resolved'] ?? '',
      favicon: json['favicon']?.isNotEmpty == true
          ? json['favicon']
          : 'assets/images/default_radio.png',
      tags: json['tags'] ?? '',
      country: json['country'] ?? '',
      bitrate: json['bitrate'] != null
          ? int.tryParse(json['bitrate'].toString())
          : null,
    );
  }
}
