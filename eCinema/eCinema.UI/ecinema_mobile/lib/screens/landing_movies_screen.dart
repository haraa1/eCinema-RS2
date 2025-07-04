import 'package:ecinema_mobile/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/showtime.dart';
import '../providers/showtime_provider.dart';
import '../providers/cinema_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/showtime_card.dart';

enum ShowtimesTab { active, upcoming, recommended }

class LandingShowtimesController extends ChangeNotifier {
  final ShowtimeProvider _showtimeProvider = ShowtimeProvider();
  final CinemaProvider _cinemaProvider = CinemaProvider();

  final List<Showtime> allShowtimes = [];
  final List<Showtime> showtimes = [];
  final Map<String, List<int>> cityMap = {};

  bool isLoading = false;
  ShowtimesTab _currentTab = ShowtimesTab.active;
  String _search = '';
  String? _selectedCity;
  String? lastLoadedLanguage;

  void reset() {
    allShowtimes.clear();
    showtimes.clear();
    cityMap.clear();
    isLoading = false;
    _currentTab = ShowtimesTab.active;
    _search = '';
    _selectedCity = null;
    lastLoadedLanguage = null;
    notifyListeners();
  }

  Future<void> load({String? language}) async {
    if (isLoading) return;

    isLoading = true;
    lastLoadedLanguage = language;
    notifyListeners();

    try {
      final cinemas = await _cinemaProvider.get();
      cityMap.clear();
      for (var cinema in cinemas) {
        cityMap.putIfAbsent(cinema.city, () => []).add(cinema.id);
      }

      final filters = <String, dynamic>{};
      if (language?.isNotEmpty ?? false) {
        filters['Language'] = language;
      }

      final page = await _showtimeProvider.get(filters);
      allShowtimes
        ..clear()
        ..addAll(page);

      if (cityMap.isNotEmpty && _selectedCity == null) {
        _selectedCity = cityMap.keys.first;
      }

      _applyFilters();
    } catch (_) {}

    isLoading = false;
    notifyListeners();
  }

  void _applyFilters() {
    final uniqueByMovie = <int, Showtime>{};

    for (var show in allShowtimes) {
      if (_selectedCity != null &&
          !(cityMap[_selectedCity]?.contains(show.cinema.id) ?? false)) {
        continue;
      }
      if (_currentTab == ShowtimesTab.active && show.movie.status != 1)
        continue;
      if (_currentTab == ShowtimesTab.upcoming && show.movie.status != 0)
        continue;
      if (_search.isNotEmpty &&
          !(show.movie.title ?? '').toLowerCase().contains(
            _search.toLowerCase(),
          )) {
        continue;
      }

      final movieId = show.movie.id!;
      if (!uniqueByMovie.containsKey(movieId) ||
          show.startTime.isBefore(uniqueByMovie[movieId]!.startTime)) {
        uniqueByMovie[movieId] = show;
      }
    }

    showtimes
      ..clear()
      ..addAll(uniqueByMovie.values);
  }

  void setCity(String city) {
    _selectedCity = city;
    _applyFilters();
    notifyListeners();
  }

  void setTab(ShowtimesTab tab) {
    _currentTab = tab;
    _applyFilters();
    notifyListeners();
  }

  void setSearch(String text) {
    _search = text.trim();
    _applyFilters();
    notifyListeners();
  }

  String get selectedCity => _selectedCity ?? 'Grad';
}

class LandingShowtimesScreen extends StatefulWidget {
  const LandingShowtimesScreen({Key? key}) : super(key: key);

  @override
  State<LandingShowtimesScreen> createState() => _LandingShowtimesScreenState();
}

class _LandingShowtimesScreenState extends State<LandingShowtimesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final ctrl = context.read<LandingShowtimesController>();
      ctrl.setTab(ShowtimesTab.values[_tabController.index]);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userProv = context.watch<UserProvider>();
    final ctrl = context.read<LandingShowtimesController>();
    final newLanguage = userProv.current?.preferredLanguage;

    if (_isInitialLoad) {
      _isInitialLoad = false;

      userProv.loadCurrentUser().then((_) {
        final initialLang = userProv.current?.preferredLanguage;
        if (mounted) {
          ctrl.load(language: initialLang);
        }
      });
    } else if (newLanguage != null && newLanguage != ctrl.lastLoadedLanguage) {
      ctrl.load(language: newLanguage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildHeader(context),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Aktivni'),
              Tab(text: 'Uskoro'),
              Tab(text: 'Preporuka'),
            ],
          ),
          Expanded(
            child: Consumer<LandingShowtimesController>(
              builder: (_, ctrl, __) {
                if (ctrl.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (ctrl.showtimes.isEmpty) {
                  return const Center(child: Text('Nema projekcija.'));
                }
                return ListView.builder(
                  itemCount: ctrl.showtimes.length,
                  itemBuilder:
                      (_, i) => ShowtimeCard(showtime: ctrl.showtimes[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildHeader(BuildContext context) {
    final ctrl = context.watch<LandingShowtimesController>();

    return AppBar(
      title: TextField(
        decoration: const InputDecoration(
          hintText: 'Pretraga filmova…',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: ctrl.setSearch,
      ),
      actions: [
        if (ctrl.cityMap.isNotEmpty)
          PopupMenuButton<String>(
            onSelected: (city) => ctrl.setCity(city),
            itemBuilder:
                (_) =>
                    ctrl.cityMap.keys
                        .map(
                          (city) =>
                              PopupMenuItem(value: city, child: Text(city)),
                        )
                        .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(ctrl.selectedCity),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),

        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Odjava',
          onPressed: () {
            final userProvider = context.read<UserProvider>();
            final showtimesController =
                context.read<LandingShowtimesController>();

            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Odjava'),
                  content: const Text(
                    'Jeste li sigurni da se želite odjaviti?',
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Odustani'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Odjavi se'),
                      onPressed: () {
                        userProvider.logout();
                        showtimesController.reset();
                        Navigator.of(dialogContext).pop();

                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
