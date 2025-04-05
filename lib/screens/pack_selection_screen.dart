import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/card_data.dart';
import '../models/card_pack.dart';
import 'card_display_screen.dart';
import '../widgets/custom_progress_indicator.dart';

class PackSelectionScreen extends StatefulWidget {
  const PackSelectionScreen({super.key});

  @override
  State<PackSelectionScreen> createState() => _PackSelectionScreenState();
}

class _PackSelectionScreenState extends State<PackSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = true;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  // Track search query
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Track selected filter category
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Couples',
    'Friends',
    'Party',
    'Deep',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _selectPack(BuildContext context, CardPack pack) {
    if (pack.questions.isEmpty) {
      _showComingSoonDialog(context, pack);
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                CardDisplayScreen(pack: pack),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.easeInOutCubic;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, CardPack pack) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Coming Soon!',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hourglass_empty, size: 50, color: pack.color),
                const SizedBox(height: 16),
                Text(
                  'The "${pack.name}" pack is currently in development and will be available soon!',
                  style: GoogleFonts.poppins(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('OK', style: TextStyle(color: pack.color)),
              ),
            ],
          ),
    );
  }

  void _showInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (ctx) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(top: 15, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(
                  'About Flamingo Cards',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoSection(
                          'How to Play',
                          'Choose a card pack that suits your mood or occasion. Tap to reveal a card, take turns answering the questions or completing the dares. Perfect for date nights, parties, or deep conversations!',
                        ),
                        _infoSection(
                          'Card Packs',
                          'We offer a variety of card packs for different occasions. From deep conversations to spicy questions for couples, we\'ve got you covered!',
                        ),
                        _infoSection(
                          'Featured Collections',
                          'Try our most popular packs: DEEP QUESTIONS, LATE NIGHT TALKS, and COUPLE THERAPY for meaningful connections.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _infoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFF4081),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  List<CardPack> get _filteredPacks {
    return allCardPacks.where((pack) {
      // Apply text search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          pack.name.toLowerCase().contains(_searchQuery) ||
          pack.description.toLowerCase().contains(_searchQuery);

      // Apply category filter
      final matchesCategory =
          _selectedCategory == 'All' ||
          pack.name.toLowerCase().contains(_selectedCategory.toLowerCase());

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Flamingo Cards',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: () => _showInfoBottomSheet(context),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              onPressed: () {
                // Settings functionality
              },
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF4081).withOpacity(0.9),
                  const Color(0xFFFF9B3D).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF5F7), Color(0xFFFFF0EA)],
            ),
          ),
          child:
              _isLoading
                  ? Center(child: CustomProgressIndicator())
                  : SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search card packs...',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey[400],
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[400],
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: Color(0xFFFF4081),
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              suffixIcon:
                                  _searchQuery.isNotEmpty
                                      ? IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                        },
                                      )
                                      : null,
                            ),
                          ),
                        ),

                        // Category filter chips
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              final isSelected = _selectedCategory == category;

                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: FilterChip(
                                  selected: isSelected,
                                  label: Text(
                                    category,
                                    style: GoogleFonts.poppins(
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                  selectedColor: const Color(0xFFFF4081),
                                  showCheckmark: false,
                                  elevation: isSelected ? 3 : 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),

                        // Featured pack if no search active
                        if (_searchQuery.isEmpty && _selectedCategory == 'All')
                          _buildFeaturedPack(),

                        Expanded(
                          child: AnimationLimiter(
                            child:
                                _filteredPacks.isEmpty
                                    ? _buildNoResultsFound()
                                    : GridView.builder(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        16,
                                        16,
                                        16,
                                      ),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 0.85,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 20,
                                          ),
                                      itemCount: _filteredPacks.length,
                                      itemBuilder: (ctx, index) {
                                        final pack = _filteredPacks[index];
                                        return AnimationConfiguration.staggeredGrid(
                                          position: index,
                                          duration: const Duration(
                                            milliseconds: 500,
                                          ),
                                          columnCount: 2,
                                          child: SlideAnimation(
                                            verticalOffset: 50.0,
                                            child: FadeInAnimation(
                                              child: PackCard(
                                                pack: pack,
                                                onTap:
                                                    () => _selectPack(
                                                      context,
                                                      pack,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
        // Floating action button for random pack
        floatingActionButton:
            _isLoading
                ? null
                : FloatingActionButton(
                  onPressed: () {
                    // Select a random pack that has questions
                    final availablePacks =
                        allCardPacks
                            .where((p) => p.questions.isNotEmpty)
                            .toList();
                    if (availablePacks.isNotEmpty) {
                      final randomIndex =
                          DateTime.now().millisecondsSinceEpoch %
                          availablePacks.length;
                      _selectPack(context, availablePacks[randomIndex]);
                    }
                  },
                  backgroundColor: const Color(0xFFFF4081),
                  child: const Icon(Icons.shuffle, color: Colors.white),
                  tooltip: 'Random Pack',
                ),
      ),
    );
  }

  Widget _buildFeaturedPack() {
    // Find a featured pack (using DEEP QUESTIONS for now)
    final featuredPack = allCardPacks.firstWhere(
      (pack) => pack.id == 'deep',
      orElse: () => allCardPacks.first,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured Pack',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _selectPack(context, featuredPack),
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    featuredPack.color,
                    featuredPack.color.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: featuredPack.color.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background decorative elements
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: -30,
                    bottom: -30,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.psychology,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                featuredPack.name,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                featuredPack.description,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 70, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No card packs found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term or category',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class PackCard extends StatelessWidget {
  final CardPack pack;
  final VoidCallback onTap;

  const PackCard({Key? key, required this.pack, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: pack.color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background decoration
              Positioned(
                right: -20,
                top: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: pack.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Opacity(
                  opacity: 0.08,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: pack.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              // Card content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: pack.color.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: pack.color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getIconForPack(pack.name),
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      pack.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Description
                    Expanded(
                      child: Text(
                        pack.description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: pack.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${pack.questions.length} cards',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: pack.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: pack.color,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Coming soon overlay
              if (pack.questions.isEmpty)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'COMING SOON',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
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
