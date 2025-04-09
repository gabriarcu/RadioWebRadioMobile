import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MetadataService {
  final String metadataServiceUrl = 'wss://backend.radiolise.com/api/data-service';
  StreamController<Map<String, dynamic>> _metadataController = StreamController<Map<String, dynamic>>.broadcast();
  Timer? _metadataTimer;
  String? _currentStreamUrl;
  
  // Espone lo stream dei metadati
  Stream<Map<String, dynamic>> get metadataStream => _metadataController.stream;
  
  // Inizia il tracciamento dei metadati per uno stream specifico
  void trackStream(String streamUrl) {
    _currentStreamUrl = streamUrl;
    _fetchMetadata(streamUrl);
  }
  
  // Ferma il tracciamento dei metadati
  void stopTracking() {
    _metadataTimer?.cancel();
    _metadataTimer = null;
    _currentStreamUrl = null;
  }
  
  // Recupera i metadati dallo stream
  Future<void> _fetchMetadata(String streamUrl) async {
    // Poiché non possiamo usare WebSocket direttamente come nell'app Vue originale,
    // simuliamo il recupero dei metadati con una chiamata HTTP
    // In una implementazione reale, si potrebbe usare un servizio di metadati HTTP
    // o implementare una connessione WebSocket
    
    try {
      // Questa è una simulazione, in un'app reale si userebbe un endpoint reale
      // che fornisce i metadati per lo stream corrente
      final response = await http.get(Uri.parse(
        'https://de1.api.radio-browser.info/json/stations/byurl/${Uri.encodeComponent(streamUrl)}'
      ));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final station = data[0];
          
          // Simuliamo i metadati con le informazioni della stazione
          final metadata = {
            'title': '${station['name']} ~ ${station['tags'] ?? ''} ~ ${DateTime.now().toString()}',
            'error': null
          };
          
          _metadataController.add(metadata);
        }
      }
    } catch (e) {
      _metadataController.add({
        'title': null,
        'error': e.toString()
      });
    }
    
    // Programma il prossimo aggiornamento
    _metadataTimer?.cancel();
    _metadataTimer = Timer(const Duration(seconds: 5), () {
      if (_currentStreamUrl != null) {
        _fetchMetadata(_currentStreamUrl!);
      }
    });
  }
  
  // Formatta i metadati grezzi
  String? formatMetadata(String? rawTitle) {
    if (rawTitle == null || rawTitle.isEmpty) {
      return null;
    }
    
    final parts = rawTitle.split('~');
    final title = parts[0]?.trim();
    final artist = parts[1]?.trim();
    final year = parts.length > 3 ? parts[3]?.trim() : null;
    
    return [
      title,
      artist,
      year != null && year.isNotEmpty ? '($year)' : null
    ].where((part) => part != null && part.isNotEmpty).join(' · ');
  }
  
  // Pulisce le risorse
  void dispose() {
    stopTracking();
    _metadataController.close();
  }
}
