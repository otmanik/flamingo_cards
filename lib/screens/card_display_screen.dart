import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:async';
import '../models/card_pack.dart';
import 'package:share_plus/share_plus.dart';
import 'package:confetti/confetti.dart';

class CardDisplayScreen extends StatefulWidget {
  final CardPack pack;

  const CardDisplayScreen({super.key, required this.pack});

  @override
  State<CardDisplayScreen> createState() => _CardDisplayScreenState();
}

class _CardDisplayScreenState extends State<CardDisplayScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late List<String> _shuffledQuestions;
  int _currentIndex = 0;
  bool _isCardFlipped = false;
  bool _isFirstLoad = true;

  // Animation controllers
  late AnimationController _flipAnimationController;
  late Animation<double> _flipAnimation;
  late ConfettiController _confettiController;

  // Timer for auto-flip
  int _remainingSeconds = 5;
  bool _isTimerRunning = false;
  Timer? _timer;

  // Favorite cards tracking
  final Set<String> _favoriteCards = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _shuffledQuestions = List.from(widget.pack.questions)..shuffle(Random());

    // Setup flip animation
    _flipAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _flipAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Setup confetti animation
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    // Haptic feedback on first load
    Future.delayed(const Duration(milliseconds: 300), () {
      HapticFeedback.mediumImpact();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _flipAnimationController.dispose();
    _confettiController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _goToNextCard() {
    if (_currentIndex < _shuffledQuestions.length - 1) {
      // Reset flip state before going to next
      setState(() {
        _isCardFlipped = false;
        _isFirstLoad = false;
      });

      _flipAnimationController.reset();
      _timer?.cancel();

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      HapticFeedback.selectionClick();
    } else {
      // At the last card, show celebration
      _confettiController.play();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "That's all the cards! Shuffle to start again.",
            style: GoogleFonts.poppins(),
          ),
          action: SnackBarAction(label: 'Shuffle', onPressed: _shuffleCards),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _goToPreviousCard() {
    if (_currentIndex > 0) {
      // Reset flip state before going to previous
      setState(() {
        _isCardFlipped = false;
        _isFirstLoad = false;
      });

      _flipAnimationController.reset();
      _timer?.cancel();

      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      HapticFeedback.selectionClick();
    }
  }

  void _toggleCardFlip() {
    setState(() {
      _isCardFlipped = !_isCardFlipped;
      _isTimerRunning = false;
      _remainingSeconds = 5;
    });

    if (_isCardFlipped) {
      _flipAnimationController.forward();
    } else {
      _flipAnimationController.reverse();
    }

    _timer?.cancel();
    HapticFeedback.lightImpact();
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _remainingSeconds = 5;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _toggleCardFlip();
          timer.cancel();
        }
      });
    });
  }

  void _shuffleCards() {
    setState(() {
      _shuffledQuestions.shuffle(Random());
      _currentIndex = 0;
      _isCardFlipped = false;
      _isFirstLoad = true;
    });

    _flipAnimationController.reset();
    _timer?.cancel();
    _pageController.jumpToPage(0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cards shuffled!', style: GoogleFonts.poppins()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleFavorite() {
    final currentQuestion = _shuffledQuestions[_currentIndex];

    setState(() {
      if (_favoriteCards.contains(currentQuestion)) {
        _favoriteCards.remove(currentQuestion);
      } else {
        _favoriteCards.add(currentQuestion);
        // Small confetti burst when adding to favorites
        _confettiController.play();
      }
    });
  }

  void _shareCard() {
    final currentQuestion = _shuffledQuestions[_currentIndex];
    Share.share(
      'Check out this card from Flamingo Cards: "$currentQuestion" #FlamingoCards',
    );
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                _buildOptionTile(
                  icon: Icons.shuffle,
                  title: 'Shuffle Cards',
                  onTap: () {
                    Navigator.pop(ctx);
                    _shuffleCards();
                  },
                ),
                _buildOptionTile(
                  icon: Icons.share,
                  title: 'Share This Card',
                  onTap: () {
                    Navigator.pop(ctx);
                    _shareCard();
                  },
                ),
                _buildOptionTile(
                  icon:
                      _favoriteCards.contains(_shuffledQuestions[_currentIndex])
                          ? Icons.favorite
                          : Icons.favorite_border,
                  title:
                      _favoriteCards.contains(_shuffledQuestions[_currentIndex])
                          ? 'Remove from Favorites'
                          : 'Add to Favorites',
                  onTap: () {
                    Navigator.pop(ctx);
                    _toggleFavorite();
                  },
                  iconColor:
                      _favoriteCards.contains(_shuffledQuestions[_currentIndex])
                          ? Colors.red
                          : null,
                ),
                _buildOptionTile(
                  icon: Icons.help_outline,
                  title: 'How to Play',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showHowToPlayDialog();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? widget.pack.color, size: 26),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  void _showHowToPlayDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              'How to Play',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: widget.pack.color,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHowToPlayStep(
                  number: '1',
                  text: 'Tap on the card to reveal the question or challenge.',
                ),
                _buildHowToPlayStep(
                  number: '2',
                  text: 'Take turns answering or completing the challenge.',
                ),
                _buildHowToPlayStep(
                  number: '3',
                  text: 'Swipe or use arrows to navigate between cards.',
                ),
                _buildHowToPlayStep(
                  number: '4',
                  text: 'Save your favorites or share cards with friends!',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Got it!',
                  style: GoogleFonts.poppins(color: widget.pack.color),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
    );
  }

  Widget _buildHowToPlayStep({required String number, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 12, top: 2),
            decoration: BoxDecoration(
              color: widget.pack.color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        widget.pack.color.computeLuminance() > 0.5
            ? Colors.black87
            : Colors.white;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.pack.name),
        backgroundColor: widget.pack.color,
        foregroundColor: textColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _favoriteCards.contains(_shuffledQuestions[_currentIndex])
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: textColor,
            ),
            onPressed: _toggleFavorite,
            tooltip: 'Favorite',
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: textColor),
            onPressed: _showOptionsBottomSheet,
            tooltip: 'More Options',
          ),
        ],
      ),
      backgroundColor: widget.pack.color.withOpacity(0.1),
      body: Stack(
        children: [
          // Confetti animation
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: [
                widget.pack.color,
                Colors.pink,
                Colors.blue,
                Colors.orange,
                Colors.purple,
                Colors.green,
              ],
            ),
          ),

          // Main content
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _shuffledQuestions.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                      _isCardFlipped = false;
                      _isFirstLoad = false;
                    });
                    _flipAnimationController.reset();
                    _timer?.cancel();
                  },
                  itemBuilder: (context, index) {
                    bool isDare = _shuffledQuestions[index]
                        .toLowerCase()
                        .startsWith('dare:');
                    String cardText =
                        isDare
                            ? _shuffledQuestions[index].substring(5).trim()
                            : _shuffledQuestions[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 40.0,
                      ),
                      child: GestureDetector(
                        onTap: _toggleCardFlip,
                        child: AnimatedBuilder(
                          animation: _flipAnimationController,
                          builder: (context, child) {
                            final angle =
                                _isCardFlipped
                                    ? (_flipAnimation.value * pi)
                                    : (1 - _flipAnimation.value) * pi;

                            return Transform(
                              transform:
                                  Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateY(angle),
                              alignment: Alignment.center,
                              child:
                                  angle < pi / 2
                                      ? _buildCardFront(
                                        isDare,
                                        cardText,
                                        textColor,
                                      )
                                      : Transform(
                                        transform:
                                            Matrix4.identity()..rotateY(pi),
                                        alignment: Alignment.center,
                                        child: _buildCardBack(
                                          isDare,
                                          cardText,
                                          textColor,
                                        ),
                                      ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Timer progress indicator (only when not flipped)
              if (_isTimerRunning && !_isCardFlipped)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    children: [
                      Text(
                        'Revealing in $_remainingSeconds',
                        style: GoogleFonts.poppins(
                          color: widget.pack.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(
                          value: _remainingSeconds / 5,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.pack.color,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),

              // Navigation controls
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 30.0,
                  left: 20,
                  right: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: widget.pack.color,
                      ),
                      onPressed: _currentIndex > 0 ? _goToPreviousCard : null,
                      tooltip: 'Previous Card',
                    ),

                    // Auto-reveal timer button
                    if (!_isTimerRunning && !_isCardFlipped)
                      IconButton(
                        icon: Icon(Icons.timer, color: widget.pack.color),
                        onPressed: _startTimer,
                        tooltip: 'Auto-reveal in 5 seconds',
                      ),

                    // Shuffle button
                    if (_isCardFlipped)
                      IconButton(
                        icon: Icon(Icons.shuffle, color: widget.pack.color),
                        onPressed: _shuffleCards,
                        tooltip: 'Shuffle Cards',
                      ),

                    Text(
                      '${_currentIndex + 1} / ${_shuffledQuestions.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: widget.pack.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Share button
                    if (_isCardFlipped)
                      IconButton(
                        icon: Icon(Icons.share, color: widget.pack.color),
                        onPressed: _shareCard,
                        tooltip: 'Share Card',
                      ),

                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: widget.pack.color,
                      ),
                      onPressed:
                          _currentIndex < _shuffledQuestions.length - 1
                              ? _goToNextCard
                              : null,
                      tooltip: 'Next Card',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront(bool isDare, String cardText, Color textColor) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.white,
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Opacity(
                opacity: 0.04,
                child: Image.network(
                  'https://www.transparenttextures.com/patterns/cubes.png',
                  repeat: ImageRepeat.repeat,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),

          // Card content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pack logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: widget.pack.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.help_outline,
                    size: 60,
                    color: widget.pack.color,
                  ),
                ),
                const SizedBox(height: 24),

                // Tap instruction
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: widget.pack.color.withOpacity(0.5),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, size: 20, color: widget.pack.color),
                      const SizedBox(width: 8),
                      Text(
                        'Tap to reveal',
                        style: GoogleFonts.poppins(
                          color: widget.pack.color,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Pack name watermark
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                widget.pack.name,
                style: GoogleFonts.poppins(
                  color: Colors.black12,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(bool isDare, String cardText, Color textColor) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: widget.pack.color,
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Opacity(
                opacity: 0.05,
                child: Image.network(
                  'https://www.transparenttextures.com/patterns/cubes.png',
                  repeat: ImageRepeat.repeat,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),

          // Card content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isDare)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: textColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'DARE!',
                            style: GoogleFonts.poppins(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    cardText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),

                  // Add favorite indicator if card is favorited
                  if (_favoriteCards.contains(
                    _shuffledQuestions[_currentIndex],
                  ))
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite, color: textColor, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'FAVORITE',
                              style: GoogleFonts.poppins(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Tap to flip back instruction
          Positioned(
            bottom: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: textColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to flip',
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
}
