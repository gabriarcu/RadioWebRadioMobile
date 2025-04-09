import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_radio_player/models/radio_station.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RadioService {
  final String apiUrl = 'https://de2.api.radio-browser.info/json/stations/search';
  final String defaultCountryCode = 'IT';
  
  // Carica le stazioni radio in base al codice paese
  Future<List<RadioStation>> fetchStations(String countryCode) async {
    try {
      final params = {
        'limit': '100',
        'countrycode': countryCode,
        'hidebroken': 'true',
        'order': 'clickcount',
        'reverse': 'true'
      };
      
      final uri = Uri.parse('$apiUrl?${_buildQueryString(params)}');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final stations = data.map((json) => RadioStation.fromJson(json)).toList();
        
        // Aggiorna lo stato dei preferiti
        final favorites = await getFavorites();
        for (var station in stations) {
          station.favorite = favorites.any((f) => f.stationuuid == station.stationuuid);
        }
        
        return stations;
      } else {
        throw Exception('Errore nel caricamento delle stazioni: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore nel caricamento delle stazioni: $e');
    }
  }
  
  // Costruisce la query string per la richiesta HTTP
  String _buildQueryString(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
  
  // Salva una stazione nei preferiti
  Future<void> toggleFavorite(RadioStation station) async {
    final prefs = await SharedPreferences.getInstance();
    List<RadioStation> favorites = await getFavorites();
    
    final index = favorites.indexWhere((f) => f.stationuuid == station.stationuuid);
    
    if (index == -1) {
      // Aggiungi ai preferiti
      favorites.add(station);
    } else {
      // Rimuovi dai preferiti
      favorites.removeAt(index);
    }
    
    // Salva in SharedPreferences
    final jsonList = favorites.map((station) => jsonEncode(station.toJson())).toList();
    await prefs.setStringList('favoriteStations', jsonList);
  }
  
  // Ottieni la lista dei preferiti
  Future<List<RadioStation>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('favoriteStations') ?? [];
    
    return jsonList
        .map((jsonString) => RadioStation.fromJson(jsonDecode(jsonString)))
        .map((station) => station.copyWith(favorite: true))
        .toList();
  }
  
  // Precarica le favicon delle stazioni
  void preloadFavicons(List<RadioStation> stations) {
    // Metodo semplificato che non utilizza precacheImage
    // per evitare problemi di compilazione
    for (var station in stations) {
      if (station.favicon.isNotEmpty) {
        // Nessuna operazione di precaching, solo per compatibilità
        print('Favicon URL: ${station.favicon}');
      }
    }
  }
}
