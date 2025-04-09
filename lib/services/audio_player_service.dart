import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_radio_player/models/radio_station.dart';
import 'package:flutter_radio_player/services/radio_service.dart';
import 'package:flutter_radio_player/services/country_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marquee/marquee.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final String defaultCover = 'https://icon-library.com/images/online-radio-icon/online-radio-icon-10.jpg';
  
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Duration?> get positionStream => _audioPlayer.positionStream;
  
  bool get isPlaying => _audioPlayer.playing;
  
  // Inizializza il player
  Future<void> init() async {
    await _audioPlayer.setLoopMode(LoopMode.off);
  }
  
  // Avvia la riproduzione
  Future<void> play(String url) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      print('Errore nella riproduzione: $e');
      rethrow;
    }
  }
  
  // Mette in pausa la riproduzione
  Future<void> pause() async {
    await _audioPlayer.pause();
  }
  
  // Ferma la riproduzione
  Future<void> stop() async {
    await _audioPlayer.stop();
  }
  
  // Rilascia le risorse
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
  
  // Ottieni l'URL dell'immagine di copertina
  String getImageUrl(String? favicon) {
    return favicon?.isNotEmpty == true ? favicon! : defaultCover;
  }
}
