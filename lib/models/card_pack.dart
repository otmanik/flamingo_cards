import 'package:flutter/material.dart'; // For Color

class CardPack {
  final String id; // Unique ID for the pack
  final String name;
  final String description;
  final List<String> questions; // Or prompts/dares
  final Color color; // Optional: for styling

  const CardPack({
    required this.id,
    required this.name,
    required this.description,
    required this.questions,
    this.color = Colors.pinkAccent, // Default color
  });
}
