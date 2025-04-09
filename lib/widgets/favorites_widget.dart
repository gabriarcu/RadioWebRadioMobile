import 'package:flutter/material.dart';
import 'package:flutter_radio_player/models/radio_station.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FavoritesWidget extends StatelessWidget {
  final List<RadioStation> favorites;
  final Function(RadioStation) onFavoriteSelected;

  const FavoritesWidget({
    Key? key,
    required this.favorites,
    required this.onFavoriteSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Nessun preferito',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: favorites.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final station = favorites[index];
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
            station.country,
            style: const TextStyle(color: Colors.white70),
          ),
          onTap: () => onFavoriteSelected(station),
        );
      },
    );
  }
}
