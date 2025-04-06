import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:radiowebradio/models/country.dart';
import 'package:radiowebradio/models/radio_station.dart';
import 'package:radiowebradio/services/radio_api.dart';
import 'package:radiowebradio/widgets/control_button.dart';
import 'package:marquee/marquee.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _countriesLoading = true;
  List<RadioStation> _stations = [];
  List<Country> _countries = [];
  String _selectedCountry = 'it';
  int _currentStationIndex = 0;
  String? _nowPlayingTitle;
  bool _isMetadataLoading = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initApp();
  }

  Future<void> _initApp() async {
    await _fetchCountries();
    await _fetchStations();
  }

  Future<void> _fetchCountries() async {
    setState(() => _countriesLoading = true);
    try {
      final api = Provider.of<RadioApi>(context, listen: false);
      _countries = await api.fetchCountries();
    } catch (e) {
      debugPrint('Error fetching countries: $e');
    } finally {
      setState(() => _countriesLoading = false);
    }
  }

  Future<void> _fetchStations() async {
    setState(() => _isLoading = true);
    try {
      final api = Provider.of<RadioApi>(context, listen: false);
      _stations =
          await api.fetchStations(countryCode: _selectedCountry.toUpperCase());
    } catch (e) {
      debugPrint('Error fetching stations: $e');
      _stations = [];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _playStation(RadioStation station) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(station.urlResolved);
      await _audioPlayer.play();
      _startMetadataTracking(station.urlResolved);
    } catch (e) {
      debugPrint('Error playing station: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error playing radio station')),
      );
    }
  }

  void _startMetadataTracking(String url) {
    setState(() => _isMetadataLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _nowPlayingTitle = 'Sample Track • Sample Artist';
        _isMetadataLoading = false;
      });
    });
  }

  void _togglePlay() async {
    if (_stations.isEmpty) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _playStation(_stations[_currentStationIndex]);
      setState(() => _isPlaying = true);
    }
  }

  void _prevStation() {
    if (_stations.isEmpty) return;

    setState(() {
      _currentStationIndex = _currentStationIndex > 0
          ? _currentStationIndex - 1
          : _stations.length - 1;
    });

    if (_isPlaying) {
      _playStation(_stations[_currentStationIndex]);
    }
  }

  void _nextStation() {
    if (_stations.isEmpty) return;

    setState(() {
      _currentStationIndex = _currentStationIndex < _stations.length - 1
          ? _currentStationIndex + 1
          : 0;
    });

    if (_isPlaying) {
      _playStation(_stations[_currentStationIndex]);
    }
  }

  void _selectCountry(String code) {
    setState(() {
      _selectedCountry = code;
      _fetchStations();
    });
  }

  void _toggleFavorite(RadioStation station) {
    setState(() {
      station.isFavorite = !station.isFavorite;
    });
  }

  String _getStationSubtitle(RadioStation station) {
    return [
      station.tags,
      station.country,
      station.bitrate != null ? '${station.bitrate}kbps' : null
    ].where((element) => element != null && element.isNotEmpty).join(' • ');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCountryMenu(),
        _buildPlaylistMenu(),
      ],
    );
  }

  Widget _buildCountryMenu() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF47494B), Color(0xFF18191D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF6A6A6A),
              blurRadius: 3,
              offset: Offset(-3, -3),
            ),
            BoxShadow(
              color: Color(0xFF050606),
              blurRadius: 3,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: const Icon(Icons.language, color: Color(0xFF6A6A6B)),
      ),
      onSelected: _selectCountry,
      itemBuilder: (context) {
        if (_countriesLoading) {
          return [
            const PopupMenuItem(
              child: Center(child: CircularProgressIndicator()),
            ),
          ];
        }
        return _countries.map((country) {
          return PopupMenuItem<String>(
            value: country.code,
            child: Row(
              children: [
                Image.network(
                  'https://flagcdn.com/w40/${country.code}.png',
                  width: 24,
                  height: 16,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 10),
                Text(country.name),
                if (_selectedCountry == country.code) ...[
                  const Spacer(),
                  const Icon(Icons.check, color: Colors.orange),
                ],
              ],
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildPlaylistMenu() {
    return PopupMenuButton<void>(
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF47494B), Color(0xFF18191D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF6A6A6A),
              blurRadius: 3,
              offset: Offset(-3, -3),
            ),
            BoxShadow(
              color: Color(0xFF050606),
              blurRadius: 3,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: const Icon(Icons.queue_music, color: Color(0xFF6A6A6B)),
      ),
      itemBuilder: (context) {
        if (_stations.isEmpty) {
          return [
            const PopupMenuItem(
              child: Text('No stations available'),
            ),
          ];
        }
        return _stations.map((station) {
          return PopupMenuItem(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  station.favicon.isNotEmpty
                      ? station.favicon
                      : 'assets/images/default_radio.png',
                ),
              ),
              title: Text(station.name),
              subtitle: Text(_getStationSubtitle(station)),
              trailing: IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: station.isFavorite ? Colors.red : null,
                ),
                onPressed: () => _toggleFavorite(station),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentStationIndex = _stations.indexOf(station);
                });
                if (_isPlaying) {
                  _playStation(station);
                }
              },
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Loading radio stations...',
              style: TextStyle(color: Color(0xFFA7A8AA))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No stations found',
        style: TextStyle(color: Color(0xFFA7A8AA)),
      ),
    );
  }

  Widget _buildMainContent() {
    final currentStation = _stations[_currentStationIndex];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF18191D), width: 10),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF444444),
                blurRadius: 5,
                offset: Offset(-5, -5),
              ),
              BoxShadow(
                color: Color(0xFF050606),
                blurRadius: 5,
                offset: Offset(5, 5),
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(
                currentStation.favicon.isNotEmpty
                    ? currentStation.favicon
                    : 'assets/images/default_radio.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 50),
        Text(
          currentStation.name,
          style: const TextStyle(
            color: Color(0xFFA7A8AA),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        if (_isPlaying && _isMetadataLoading)
          const SizedBox(
            height: 30,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_isPlaying)
          Image.asset('assets/images/wave.gif', height: 30),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: _nowPlayingTitle != null
              ? Marquee(
                  text: _nowPlayingTitle!,
                  style: const TextStyle(
                    color: Color(0xFF6A6A6A),
                    fontSize: 16,
                  ),
                  velocity: 50.0,
                  blankSpace: 20.0,
                  pauseAfterRound: const Duration(seconds: 1),
                  startPadding: 10.0,
                )
              : Text(
                  _getStationSubtitle(currentStation),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF6A6A6A),
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ],
    );
  }

  Widget _buildPlayerControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ControlButton(
            icon: Icons.skip_previous,
            onPressed: _prevStation,
          ),
          const SizedBox(width: 20),
          ControlButton(
            icon: _isPlaying ? Icons.pause : Icons.play_arrow,
            isPrimary: true,
            isActive: _isPlaying,
            onPressed: _togglePlay,
          ),
          const SizedBox(width: 20),
          ControlButton(
            icon: Icons.skip_next,
            onPressed: _nextStation,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232528),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? _buildLoading()
                    : _stations.isEmpty
                        ? _buildEmptyState()
                        : _buildMainContent(),
              ),
              if (!_isLoading && _stations.isNotEmpty) _buildPlayerControls(),
            ],
          ),
        ),
      ),
    );
  }
}
