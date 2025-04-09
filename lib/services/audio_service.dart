import 'package:flutter/material.dart';
import 'package:flutter_radio_player/services/metadata_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final MetadataService _metadataService = MetadataService();
  
  // Stato del player
  bool get isPlaying => _audioPlayer.playing;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Map<String, dynamic>> get metadataStream => _metadataService.metadataStream;
  
  // Inizializza il servizio audio
  Future<void> init() async {
    await _audioPlayer.setLoopMode(LoopMode.off);
    
    // Ascolta gli eventi di riproduzione
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // La riproduzione è terminata
        _metadataService.stopTracking();
      }
    });
  }
  
  // Avvia la riproduzione di una stazione radio
  Future<void> play(String url) async {
    try {
      await _audioPlayer.stop();
      
      // Gestisce sia gli stream HLS (m3u8) che gli stream diretti
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      
      // Avvia il tracciamento dei metadati
      _metadataService.trackStream(url);
    } catch (e) {
      print('Errore nella riproduzione: $e');
      rethrow;
    }
  }
  
  // Mette in pausa la riproduzione
  Future<void> pause() async {
    await _audioPlayer.pause();
    _metadataService.stopTracking();
  }
  
  // Ferma la riproduzione
  Future<void> stop() async {
    await _audioPlayer.stop();
    _metadataService.stopTracking();
  }
  
  // Formatta i metadati
  String? formatMetadata(String? rawTitle) {
    return _metadataService.formatMetadata(rawTitle);
  }
  
  // Rilascia le risorse
  Future<void> dispose() async {
    await _audioPlayer.dispose();
    _metadataService.dispose();
  }
}
