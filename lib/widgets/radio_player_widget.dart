import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_radio_player/models/radio_station.dart';
import 'package:flutter_radio_player/services/audio_player_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marquee/marquee.dart';

class RadioPlayerWidget extends StatelessWidget {
  final RadioStation? currentStation;
  final bool isPlaying;
  final String? nowPlayingTitle;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const RadioPlayerWidget({
    Key? key,
    required this.currentStation,
    required this.isPlaying,
    this.nowPlayingTitle,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioService = Provider.of<AudioPlayerService>(context, listen: false);
    
    return Column(
      children: [
        // Album/Station Image
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
            image: DecorationImage(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(
                currentStation?.favicon?.isNotEmpty == true
                    ? currentStation!.favicon
                    : audioService.defaultCover,
              ),
            ),
          ),
        ),
        
        // Station Info
        const SizedBox(height: 50),
        Text(
          currentStation?.name ?? 'Sconosciuto',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFA7A8AA),
          ),
          textAlign: TextAlign.center,
        ),
        
        // Progress/Wave Animation
        Container(
          height: 30,
          alignment: Alignment.center,
          child: isPlaying
              ? Image.asset('assets/images/wave.gif', height: 15)
              : const SizedBox(height: 15),
        ),
        
        // Now Playing Title with Marquee
        Container(
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: nowPlayingTitle != null && nowPlayingTitle!.isNotEmpty
              ? Marquee(
                  text: nowPlayingTitle!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6A6A6A),
                  ),
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  blankSpace: 20.0,
                  velocity: 30.0,
                  pauseAfterRound: const Duration(seconds: 1),
                  startPadding: 10.0,
                  accelerationDuration: const Duration(seconds: 1),
                  accelerationCurve: Curves.linear,
                  decelerationDuration: const Duration(milliseconds: 500),
                  decelerationCurve: Curves.easeOut,
                )
              : Text(
                  _buildStationSubtitle(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6A6A6A),
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
        
        // Player Controls
        const SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous Button
            _buildControlButton(
              onPressed: onPrevious,
              icon: Icons.skip_previous,
              isActive: false,
            ),
            
            // Play/Pause Button
            const SizedBox(width: 20),
            _buildControlButton(
              onPressed: onPlayPause,
              icon: isPlaying ? Icons.pause : Icons.play_arrow,
              isActive: isPlaying,
              isPlayPause: true,
            ),
            
            // Next Button
            const SizedBox(width: 20),
            _buildControlButton(
              onPressed: onNext,
              icon: Icons.skip_next,
              isActive: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required bool isActive,
    bool isPlayPause = false,
  }) {
    return Container(
      width: isPlayPause ? 80 : 60,
      height: isPlayPause ? 80 : 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [const Color(0xFFE8550C), const Color(0xFFF47333)]
              : [const Color(0xFF47494B), const Color(0xFF18191D)],
        ),
        border: Border.all(
          color: isActive ? const Color(0xFFE8550C) : const Color(0xFF2F3139),
          width: isPlayPause ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isActive ? Colors.white : const Color(0xFF84878A),
          size: isPlayPause ? 40 : 30,
        ),
        onPressed: onPressed,
      ),
    );
  }

  String _buildStationSubtitle() {
    if (currentStation == null) return '';
    
    final parts = [
      currentStation!.tags,
      currentStation!.country,
      if (currentStation!.bitrate > 0) '${currentStation!.bitrate}kbps',
    ].where((part) => part.isNotEmpty).toList();
    
    return parts.join(' • ');
  }
}
