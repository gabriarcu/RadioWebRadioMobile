import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_radio_player/models/radio_station.dart';
import 'package:flutter_radio_player/models/country.dart';
import 'package:flutter_radio_player/services/radio_service.dart';
import 'package:flutter_radio_player/services/country_service.dart';
import 'package:flutter_radio_player/services/audio_service.dart';
import 'package:flutter_radio_player/widgets/radio_player_widget.dart';
import 'package:flutter_radio_player/widgets/stations_list_widget.dart';
import 'package:flutter_radio_player/widgets/country_selection_widget.dart';
import 'package:flutter_radio_player/widgets/favorites_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RadioService _radioService = RadioService();
  final CountryService _countryService = CountryService();
  final AudioService _audioService = AudioService();
  
  List<RadioStation> _stations = [];
  List<Country> _countries = [];
  List<RadioStation> _favorites = [];
  
  bool _isLoading = true;
  bool _isCountriesLoading = true;
  bool _isPlaying = false;
  
  String _selectedCountryCode = 'it';
  int _currentStationIndex = 0;
  String? _nowPlayingTitle;
  
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    await _audioService.init();
    
    // Carica i paesi
    _loadCountries();
    
    // Carica le stazioni
    _loadStations(_selectedCountryCode);
    
    // Carica i preferiti
    _loadFavorites();
    
    // Ascolta lo stato del player
    _audioService.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
    
    // Ascolta i metadati
    _audioService.metadataStream.listen((metadata) {
      final title = metadata['title'];
      if (title != null) {
        setState(() {
          _nowPlayingTitle = _audioService.formatMetadata(title);
        });
      }
    });
  }
  
  Future<void> _loadCountries() async {
    try {
      setState(() {
        _isCountriesLoading = true;
      });
      
      final countries = await _countryService.fetchCountryCodes();
      
      setState(() {
        _countries = countries;
        _isCountriesLoading = false;
      });
    } catch (e) {
      print('Errore nel caricamento dei paesi: $e');
      setState(() {
        _isCountriesLoading = false;
      });
    }
  }
  
  Future<void> _loadStations(String countryCode) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final stations = await _radioService.fetchStations(countryCode.toUpperCase());
      
      setState(() {
        _stations = stations;
        _isLoading = false;
        
        // Aggiorna lo stato dei preferiti
        _updateStationFavorites();
        
        // Imposta la stazione corrente
        if (_stations.isNotEmpty) {
          _currentStationIndex = 0;
        }
      });
    } catch (e) {
      print('Errore nel caricamento delle stazioni: $e');
      setState(() {
        _stations = [];
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadFavorites() async {
    try {
      final favorites = await _radioService.getFavorites();
      
      setState(() {
        _favorites = favorites;
        _updateStationFavorites();
      });
    } catch (e) {
      print('Errore nel caricamento dei preferiti: $e');
    }
  }
  
  void _updateStationFavorites() {
    for (var station in _stations) {
      station.favorite = _favorites.any((f) => f.stationuuid == station.stationuuid);
    }
  }
  
  void _selectCountry(String countryCode) {
    setState(() {
      _selectedCountryCode = countryCode;
    });
    
    _loadStations(countryCode);
    Navigator.pop(context); // Chiude il menu
  }
  
  void _toggleFavorite(RadioStation station) async {
    // Aggiorna lo stato del preferito
    setState(() {
      station.favorite = !station.favorite;
      
      if (station.favorite) {
        _favorites.add(station);
      } else {
        _favorites.removeWhere((f) => f.stationuuid == station.stationuuid);
      }
    });
    
    // Salva i preferiti
    await _radioService.toggleFavorite(station);
  }
  
  void _switchStation(int index) {
    setState(() {
      _currentStationIndex = index;
      _nowPlayingTitle = null;
    });
    
    if (_isPlaying) {
      _stopPlayback();
      _startPlayback();
    }
  }
  
  void _playFavorite(RadioStation station) {
    final index = _stations.indexWhere((s) => s.stationuuid == station.stationuuid);
    
    if (index != -1) {
      _switchStation(index);
    }
    
    Navigator.pop(context); // Chiude il menu
  }
  
  void _playPause() {
    if (_stations.isEmpty) return;
    
    if (_isPlaying) {
      _stopPlayback();
    } else {
      _startPlayback();
    }
  }
  
  void _startPlayback() async {
    if (_stations.isEmpty || _currentStationIndex >= _stations.length) return;
    
    final station = _stations[_currentStationIndex];
    
    try {
      await _audioService.play(station.urlResolved);
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      print('Errore nella riproduzione: $e');
    }
  }
  
  void _stopPlayback() async {
    await _audioService.stop();
    setState(() {
      _isPlaying = false;
      _nowPlayingTitle = null;
    });
  }
  
  void _prevStation() {
    if (_stations.isEmpty) return;
    
    final newIndex = _currentStationIndex > 0
        ? _currentStationIndex - 1
        : _stations.length - 1;
    
    _switchStation(newIndex);
  }
  
  void _nextStation() {
    if (_stations.isEmpty) return;
    
    final newIndex = _currentStationIndex < _stations.length - 1
        ? _currentStationIndex + 1
        : 0;
    
    _switchStation(newIndex);
  }
  
  void _showStationsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF232528),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stazioni Radio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StationsListWidget(
                stations: _stations,
                currentStationIndex: _currentStationIndex,
                onStationSelected: (index) {
                  _switchStation(index);
                  Navigator.pop(context);
                },
                onToggleFavorite: _toggleFavorite,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Chiudi'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showCountriesMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF232528),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleziona Paese',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: CountrySelectionWidget(
                countries: _countries,
                selectedCountryCode: _selectedCountryCode,
                onCountrySelected: _selectCountry,
                isLoading: _isCountriesLoading,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Chiudi'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showFavoritesMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF232528),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferiti',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FavoritesWidget(
                favorites: _favorites,
                onFavoriteSelected: _playFavorite,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Chiudi'),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final currentStation = _stations.isNotEmpty && _currentStationIndex < _stations.length
        ? _stations[_currentStationIndex]
        : null;
    
    return Scaffold(
      backgroundColor: const Color(0xFFD5DBDB),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(35),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF343A3F), Color(0xFF232528)],
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF393B3C),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Header con i pulsanti menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.playlist_play),
                    color: const Color(0xFF6A6A6B),
                    onPressed: _showStationsMenu,
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite),
                    color: _favorites.isNotEmpty
                        ? Colors.red.shade700
                        : const Color(0xFF6A6A6B),
                    onPressed: _showFavoritesMenu,
                  ),
                  IconButton(
                    icon: const Icon(Icons.public),
                    color: const Color(0xFF6A6A6B),
                    onPressed: _showCountriesMenu,
                  ),
                ],
              ),
              
              // Corpo principale
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Caricamento stazioni radio...',
                              style: TextStyle(color: Color(0xFFA7A8AA)),
                            ),
                          ],
                        ),
                      )
                    : _stations.isEmpty
                        ? const Center(
                            child: Text(
                              'Nessuna stazione trovata',
                              style: TextStyle(color: Color(0xFFA7A8AA)),
                            ),
                          )
                        : RadioPlayerWidget(
                            currentStation: currentStation,
                            isPlaying: _isPlaying,
                            nowPlayingTitle: _nowPlayingTitle,
                            onPlayPause: _playPause,
                            onPrevious: _prevStation,
                            onNext: _nextStation,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
