import 'package:flutter/material.dart';
import 'dart:math'; // For random shuffle
import '../models/card_pack.dart';

class CardDisplayScreen extends StatefulWidget {
  final CardPack pack;

  const CardDisplayScreen({super.key, required this.pack});

  @override
  State<CardDisplayScreen> createState() => _CardDisplayScreenState();
}

class _CardDisplayScreenState extends State<CardDisplayScreen> {
  late PageController _pageController;
  late List<String> _shuffledQuestions;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Shuffle the questions when the screen loads
    _shuffledQuestions = List.from(widget.pack.questions)..shuffle(Random());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextCard() {
    if (_currentIndex < _shuffledQuestions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Optional: Show a message or loop back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You've reached the end of the pack!"),
          duration: Duration(seconds: 2),
        ),
      );
      // Or loop back: _pageController.jumpToPage(0);
    }
  }

  void _goToPreviousCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine a contrasting text color based on pack color brightness
    final textColor =
        widget.pack.color.computeLuminance() > 0.5
            ? Colors.black87
            : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pack.name),
        backgroundColor: widget.pack.color, // Match app bar to pack color
        foregroundColor: textColor, // Set AppBar text/icon color
      ),
      backgroundColor: widget.pack.color.withOpacity(
        0.1,
      ), // Subtle background tint
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _shuffledQuestions.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                // Handle potential 'Dare:' prefix for spicy pack
                bool isDare = _shuffledQuestions[index]
                    .toLowerCase()
                    .startsWith('dare:');
                String cardText =
                    isDare
                        ? _shuffledQuestions[index]
                            .substring(5)
                            .trim() // Remove 'Dare:'
                        : _shuffledQuestions[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 40.0,
                  ),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    color: widget.pack.color, // Card color matches pack
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isDare) // Show DARE label if applicable
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                margin: const EdgeInsets.only(bottom: 15),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'DARE!',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            Text(
                              cardText,
                              textAlign: TextAlign.center,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                color: textColor, // Use contrasting text color
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Card Indicator and Navigation
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: widget.pack.color),
                  onPressed:
                      _currentIndex > 0
                          ? _goToPreviousCard
                          : null, // Disable if first card
                  tooltip: 'Previous Card',
                ),
                Text(
                  '${_currentIndex + 1} / ${_shuffledQuestions.length}',
                  style: TextStyle(fontSize: 16, color: widget.pack.color),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: widget.pack.color),
                  onPressed:
                      _currentIndex < _shuffledQuestions.length - 1
                          ? _goToNextCard
                          : null, // Disable if last card
                  tooltip: 'Next Card',
                ),
              ],
            ),
          ),
        ],
      ),
      // Optional: Add a floating action button for next card as well
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _goToNextCard,
      //   backgroundColor: widget.pack.color,
      //   foregroundColor: textColor,
      //   tooltip: 'Next Card',
      //   child: const Icon(Icons.arrow_forward),
      // ),
    );
  }
}
