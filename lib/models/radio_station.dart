class RadioStation {
  final String stationuuid;
  final String name;
  final String url;
  final String urlResolved;
  final String favicon;
  final String country;
  final String tags;
  final int bitrate;
  bool favorite;

  RadioStation({
    required this.stationuuid,
    required this.name,
    required this.url,
    required this.urlResolved,
    required this.favicon,
    required this.country,
    required this.tags,
    required this.bitrate,
    this.favorite = false,
  });

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      stationuuid: json['stationuuid'] ?? '',
      name: json['name'] ?? 'Sconosciuto',
      url: json['url'] ?? '',
      urlResolved: json['url_resolved'] ?? '',
      favicon: json['favicon'] ?? '',
      country: json['country'] ?? '',
      tags: json['tags'] ?? '',
      bitrate: json['bitrate'] != null ? int.tryParse(json['bitrate'].toString()) ?? 0 : 0,
      favorite: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stationuuid': stationuuid,
      'name': name,
      'url': url,
      'url_resolved': urlResolved,
      'favicon': favicon,
      'country': country,
      'tags': tags,
      'bitrate': bitrate,
    };
  }

  RadioStation copyWith({
    String? stationuuid,
    String? name,
    String? url,
    String? urlResolved,
    String? favicon,
    String? country,
    String? tags,
    int? bitrate,
    bool? favorite,
  }) {
    return RadioStation(
      stationuuid: stationuuid ?? this.stationuuid,
      name: name ?? this.name,
      url: url ?? this.url,
      urlResolved: urlResolved ?? this.urlResolved,
      favicon: favicon ?? this.favicon,
      country: country ?? this.country,
      tags: tags ?? this.tags,
      bitrate: bitrate ?? this.bitrate,
      favorite: favorite ?? this.favorite,
    );
  }
}
