import 'package:flutter/material.dart';
import 'package:flutter_radio_player/models/country.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CountryService {
  final String flagApiUrl = 'https://flagcdn.com/it/codes.json';
  
  // Carica i codici dei paesi
  Future<List<Country>> fetchCountryCodes() async {
    try {
      final response = await http.get(Uri.parse(flagApiUrl));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Converti la mappa in una lista di oggetti Country
        final countries = data.entries
            .map((entry) => Country(
                  code: entry.key.toLowerCase(),
                  name: entry.value,
                ))
            .toList();
        
        // Ordina i paesi per nome
        countries.sort((a, b) => a.name.compareTo(b.name));
        
        return countries;
      } else {
        throw Exception('Errore nel caricamento dei paesi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore nel caricamento dei paesi: $e');
    }
  }
  
  // Ottieni l'URL della bandiera per un codice paese
  String getFlagUrl(String countryCode) {
    return 'https://flagcdn.com/w40/${countryCode.toLowerCase()}.png';
  }
}
