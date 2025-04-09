import 'package:flutter/material.dart';
import 'package:flutter_radio_player/models/country.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CountrySelectionWidget extends StatelessWidget {
  final List<Country> countries;
  final String selectedCountryCode;
  final Function(String) onCountrySelected;
  final bool isLoading;

  const CountrySelectionWidget({
    Key? key,
    required this.countries,
    required this.selectedCountryCode,
    required this.onCountrySelected,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (countries.isEmpty) {
      return const Center(
        child: Text(
          'Nessun paese disponibile',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      itemCount: countries.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final country = countries[index];
        return ListTile(
          leading: CachedNetworkImage(
            imageUrl: 'https://flagcdn.com/w40/${country.code}.png',
            width: 40,
            placeholder: (context, url) => const SizedBox(
              width: 40,
              height: 30,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          title: Text(
            country.name,
            style: const TextStyle(color: Colors.white),
          ),
          trailing: selectedCountryCode == country.code
              ? const Icon(Icons.check, color: Colors.blue)
              : null,
          onTap: () => onCountrySelected(country.code),
        );
      },
    );
  }
}
