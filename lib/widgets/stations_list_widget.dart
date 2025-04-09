import 'package:flutter/material.dart';
import 'package:flutter_radio_player/models/radio_station.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StationsListWidget extends StatelessWidget {
  final List<RadioStation> stations;
  final int currentStationIndex;
  final Function(int) onStationSelected;
  final Function(RadioStation) onToggleFavorite;

  const StationsListWidget({
    Key? key,
    required this.stations,
    required this.currentStationIndex,
    required this.onStationSelected,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Nessuna stazione disponibile',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: stations.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final station = stations[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              station.favicon.isNotEmpty
                  ? station.favicon
                  : 'https://icon-library.com/images/online-radio-icon/online-radio-icon-10.jpg',
            ),
          ),
          title: Text(
            station.name,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            '${station.country} • ${station.bitrate}kbps',
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.favorite,
              color: station.favorite ? Colors.red : Colors.grey,
            ),
            onPressed: () => onToggleFavorite(station),
          ),
          selected: currentStationIndex == index,
          selectedTileColor: Colors.white.withOpacity(0.1),
          selectedColor: Colors.white,
          onTap: () => onStationSelected(index),
          shape: currentStationIndex == index
              ? const Border(
                  left: BorderSide(
                    color: Color(0xFFE8550C),
                    width: 4,
                  ),
                )
              : null,
        );
      },
    );
  }
}
