import 'package:flutter/material.dart'; // For Color

class CardPack {
  final String id; // Unique ID for the pack
  final String name;
  final String description;
  final List<String> questions; // Or prompts/dares
  final Color color; // Optional: for styling
  final String category;
  final bool isPremium; // Added isPremium field

  const CardPack({
    required this.id,
    required this.name,
    required this.description,
    required this.questions,
    this.color = Colors.pinkAccent, // Default color
    this.category = "ALL", // Default category
    this.isPremium = false, // Added default value for isPremium
  });
}
