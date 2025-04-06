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

  // Use the same key as in CardDisplayScreen
  static const String _favoritesPrefKey = 'favoriteCardQuestions';

  @override
  void initState() {
    super.initState();
    // Load settings and favorites initially
    _loadSettingsAndFavorites();
  }

  // Combined loading function for settings and favorites
  Future<void> _loadSettingsAndFavorites() async {
    setState(() {
      _isLoading = true; // Show loading indicator while fetching
    });
    final prefs = await SharedPreferences.getInstance();
    final darkModeSetting =
        prefs.getBool('darkMode') ?? true; // Default to true if not set
    final favoriteList = prefs.getStringList(_favoritesPrefKey) ?? [];

    final List<Map<String, dynamic>> loadedFavorites = [];

    // Find the pack for each favorite question
    for (final favoriteQuestion in favoriteList) {
      for (final pack in allCardPacks) {
        if (pack.questions.contains(favoriteQuestion)) {
          loadedFavorites.add({'question': favoriteQuestion, 'pack': pack});
          break; // Found the pack, move to the next favorite
        }
      }
      // Optional: Handle case where a favorite question's pack is no longer available
    }

    // Update state only after loading is complete
    if (mounted) {
      // Check if the widget is still in the tree
      setState(() {
        _darkMode = darkModeSetting;
        _favoriteCards = loadedFavorites;
        _isLoading = false;
      });
    }
  }

  // Updated removeFromFavorites to use SharedPreferences
  Future<void> _removeFromFavorites(String question) async {
    final prefs = await SharedPreferences.getInstance();
    // Make a mutable copy
    final favorites = List<String>.from(
      prefs.getStringList(_favoritesPrefKey) ?? [],
    );

    favorites.remove(question); // Remove the specific question
    await prefs.setStringList(
      _favoritesPrefKey,
      favorites,
    ); // Save the updated list

    // Update the local state to reflect the change immediately
    setState(() {
      _favoriteCards.removeWhere((item) => item['question'] == question);
    });

    // Show feedback
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

    // Create a temporary pack containing only the selected favorite question
    final customPack = CardPack(
      id: 'favorite_${pack.id}', // Unique ID for this temporary pack view
      name: 'From: ${pack.name}', // Indicate the origin pack
      description: 'Your favorite card',
      questions: [question], // Only this question
      color: pack.color,
      category: pack.category, // Keep original category if needed
    );

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => CardDisplayScreen(pack: customPack),
          ),
        )
        .then((_) {
          // Reload favorites when returning from the single card view
          // as the user might have unfavorited it there.
          _loadSettingsAndFavorites(); // Reload both settings and favorites
        });
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on the loaded _darkMode state
    final appBarColor = _darkMode ? Colors.grey[850] : const Color(0xFFFF4081);
    final scaffoldBackgroundColor =
        _darkMode ? const Color(0xFF121212) : Colors.grey[100];
    final titleColor =
        _darkMode
            ? Colors.white
            : Colors.white; // Keep title white for pink bar

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Favorites',
          style: GoogleFonts.poppins(color: titleColor),
        ),
        backgroundColor: appBarColor,
        foregroundColor: titleColor, // Ensure back button matches title
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: titleColor),
            // Reload both settings and favorites on refresh
            onPressed: _loadSettingsAndFavorites,
            tooltip: 'Refresh Favorites',
          ),
        ],
      ),
      backgroundColor: scaffoldBackgroundColor,
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  // Use theme color or specific color based on dark mode
                  color: _darkMode ? Colors.white70 : const Color(0xFFFF4081),
                ),
              )
              : _favoriteCards.isEmpty
              ? _buildEmptyState()
              : _buildFavoritesList(),
    );
  }

  Widget _buildEmptyState() {
    final textColor = _darkMode ? Colors.white70 : Colors.grey[700];
    final secondaryTextColor = _darkMode ? Colors.grey[400] : Colors.grey[600];
    final iconColor = _darkMode ? Colors.grey[600] : Colors.grey[400];

    return Center(
      child: Padding(
        // Added padding for better spacing
        padding: const EdgeInsets.all(32.0),
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
              'Add cards to your favorites by tapping the heart icon ❤️ while viewing a card.', // Updated text slightly
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate back to the pack selection or previous screen
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.explore_outlined), // Changed icon
              label: Text('Explore Card Packs', style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                // Use theme's primary color
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white, // Ensure text is visible
              ),
            ),
          ],
        ),
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

        final cardColor = _darkMode ? const Color(0xFF2C2C2C) : Colors.white;
        final textColor = _darkMode ? Colors.white : Colors.black87;
        final packTitleColor =
            pack.color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Dismissible(
            key: Key(question), // Use the unique question as the key
            direction:
                DismissDirection.endToStart, // Only allow swipe left to delete
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.redAccent, // Use a slightly less intense red
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                // Add text indication
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Remove',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.delete_sweep_outlined, color: Colors.white),
                ],
              ),
            ),
            onDismissed: (direction) {
              // This calls the updated function which handles SharedPreferences
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
                              ? Colors.black.withOpacity(
                                0.5,
                              ) // Darker shadow for dark mode
                              : pack.color.withOpacity(
                                0.15,
                              ), // Lighter shadow for light mode
                      blurRadius: 8, // Reduced blur
                      offset: const Offset(0, 5), // Slightly adjusted offset
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with pack name and icon
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10, // Slightly reduced vertical padding
                      ),
                      decoration: BoxDecoration(
                        color:
                            pack.color, // Use pack color for header background
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getIconForPack(pack.name),
                            color:
                                packTitleColor, // Use calculated contrast color
                            size: 18, // Slightly smaller icon
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            // Allow pack name to expand
                            child: Text(
                              pack.name,
                              style: GoogleFonts.poppins(
                                color:
                                    packTitleColor, // Use calculated contrast color
                                fontWeight: FontWeight.w600,
                                fontSize: 13, // Slightly smaller font
                              ),
                              overflow:
                                  TextOverflow.ellipsis, // Prevent overflow
                            ),
                          ),
                          // Only show Dare indicator if applicable
                          if (isDare)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(
                                  0.2,
                                ), // Darker indicator
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'DARE',
                                style: GoogleFonts.poppins(
                                  color: packTitleColor, // Use contrast color
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9, // Smaller font for indicator
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Body with question and remove button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        12,
                        8,
                        12,
                      ), // Adjusted padding
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .center, // Center align items vertically
                        children: [
                          Expanded(
                            child: Text(
                              displayText,
                              style: GoogleFonts.poppins(
                                fontSize:
                                    15, // Slightly smaller font for question
                                color: textColor,
                                height: 1.45, // Adjusted line height
                              ),
                              maxLines:
                                  4, // Limit lines to prevent excessive height
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Explicit remove button (optional, as dismissible handles it)
                          // IconButton(
                          //   icon: Icon(Icons.favorite, color: Colors.red[400]),
                          //   iconSize: 22,
                          //   onPressed: () => _removeFromFavorites(question),
                          //   tooltip: 'Remove from favorites',
                          //   visualDensity: VisualDensity.compact, // Make it smaller
                          //   padding: EdgeInsets.zero, // Remove padding
                          //   constraints: BoxConstraints(), // Remove constraints
                          // ),
                          // Added an arrow to indicate tappability
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey[400],
                            size: 20,
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
    if (name.contains('deep')) return Icons.psychology_outlined;
    if (name.contains('couple') ||
        name.contains('soulmates') ||
        name.contains('distance'))
      return Icons.favorite_outline;
    if (name.contains('tea') ||
        name.contains('juicy') ||
        name.contains('confessions'))
      return Icons.chat_bubble_outline;
    if (name.contains('late') || name.contains('night'))
      return Icons.nightlight_outlined;
    if (name.contains('friend') || name.contains('sibling'))
      return Icons.people_outline;
    if (name.contains('therapy')) return Icons.healing_outlined;
    if (name.contains('spicy') || name.contains('naughty'))
      return Icons.whatshot_outlined;
    if (name.contains('rather')) return Icons.compare_arrows_outlined;
    if (name.contains('getting')) return Icons.emoji_people_outlined;
    return Icons.style_outlined; // Generic fallback icon
  }
}
