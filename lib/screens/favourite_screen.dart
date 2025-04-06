import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_pack.dart';
import '../data/card_data.dart';
import 'card_display_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> _favoriteCards = [];
  bool _isLoading = true;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load dark mode setting
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
    });

    // Then load favorites
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favoriteCards') ?? [];

    final List<Map<String, dynamic>> loadedFavorites = [];

    // Find which pack each favorite belongs to
    for (final favorite in favorites) {
      for (final pack in allCardPacks) {
        if (pack.questions.contains(favorite)) {
          loadedFavorites.add({'question': favorite, 'pack': pack});
          break;
        }
      }
    }

    setState(() {
      _favoriteCards = loadedFavorites;
      _isLoading = false;
    });
  }

  Future<void> _removeFromFavorites(String question) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favoriteCards') ?? [];

    favorites.remove(question);
    await prefs.setStringList('favoriteCards', favorites);

    setState(() {
      _favoriteCards.removeWhere((item) => item['question'] == question);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed from favorites', style: GoogleFonts.poppins()),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openCard(Map<String, dynamic> favoriteCard) {
    final CardPack pack = favoriteCard['pack'];
    final String question = favoriteCard['question'];

    // Create a custom pack with just this card first
    final customPack = CardPack(
      id: 'favorite_${pack.id}',
      name: 'From ${pack.name}',
      description: 'Your favorite card',
      questions: [question],
      color: pack.color,
    );

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => CardDisplayScreen(pack: customPack),
          ),
        )
        .then((_) {
          // Reload settings when returning from card display
          _loadSettings();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Favorites', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFFF4081),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
            tooltip: 'Refresh',
          ),
        ],
      ),
      backgroundColor: _darkMode ? const Color(0xFF121212) : Colors.grey[100],
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: _darkMode ? Colors.white70 : null,
                ),
              )
              : _favoriteCards.isEmpty
              ? _buildEmptyState()
              : _buildFavoritesList(),
    );
  }

  Widget _buildEmptyState() {
    final textColor = _darkMode ? Colors.white : Colors.grey[700];
    final secondaryTextColor = _darkMode ? Colors.grey[400] : Colors.grey[600];
    final iconColor = _darkMode ? Colors.grey[600] : Colors.grey[400];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: iconColor),
          const SizedBox(height: 24),
          Text(
            'No Favorites Yet',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add cards to your favorites by tapping the heart icon while viewing a card.',
            style: GoogleFonts.poppins(fontSize: 16, color: secondaryTextColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.explore),
            label: Text('Explore Cards', style: GoogleFonts.poppins()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favoriteCards.length,
      itemBuilder: (context, index) {
        final item = _favoriteCards[index];
        final CardPack pack = item['pack'];
        final String question = item['question'];

        final isDare = question.toLowerCase().startsWith('dare:');
        final displayText = isDare ? question.substring(5).trim() : question;

        // Card colors based on dark mode
        final cardColor = _darkMode ? const Color(0xFF2C2C2C) : Colors.white;
        final textColor = _darkMode ? Colors.white : Colors.black87;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Dismissible(
            key: Key(question),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _removeFromFavorites(question);
            },
            child: GestureDetector(
              onTap: () => _openCard(item),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color:
                          _darkMode
                              ? Colors.black.withOpacity(0.3)
                              : pack.color.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card header with pack info
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: pack.color,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getIconForPack(pack.name),
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            pack.name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          if (isDare)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'DARE',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Card content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              displayText,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: textColor,
                                height: 1.4,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () => _removeFromFavorites(question),
                            tooltip: 'Remove from favorites',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForPack(String packName) {
    final name = packName.toLowerCase();
    if (name.contains('deep')) return Icons.psychology;
    if (name.contains('couple') || name.contains('soulmates'))
      return Icons.favorite;
    if (name.contains('tea') ||
        name.contains('juicy') ||
        name.contains('confessions'))
      return Icons.chat_bubble;
    if (name.contains('late') || name.contains('night'))
      return Icons.nightlight_round;
    if (name.contains('friend')) return Icons.people;
    if (name.contains('therapy')) return Icons.healing;
    if (name.contains('sibling')) return Icons.family_restroom;
    if (name.contains('distance')) return Icons.flight;
    if (name.contains('spicy') || name.contains('naughty'))
      return Icons.whatshot;
    if (name.contains('rather')) return Icons.compare_arrows;
    if (name.contains('getting')) return Icons.emoji_people;
    return Icons.card_giftcard;
  }
}
