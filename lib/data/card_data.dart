import '../models/card_pack.dart';
import 'package:flutter/material.dart';

// --- Placeholder Questions ---
// In a real app, you'd have many more questions per pack!
const List<String> deepQuestions = [
  "What belief do you hold that you wish you didn't?",
  "What's something you're afraid to ask for?",
  "If you could relive one day, which would it be and why?",
  "What's a hard truth you had to accept recently?",
  "What does 'fulfillment' mean to you right now?",
];

const List<String> coupleQuestions = [
  "What's one small thing I do that makes you feel loved?",
  "Describe a moment you felt proud of us as a couple.",
  "What's a shared dream you want to work towards?",
  "How can I support you better this week?",
  "What's your favorite non-physical quality about me?",
];

const List<String> spillTheTea = [
  "What's the juiciest rumor you've heard lately (don't name names!)?",
  "Describe the most dramatic situation you've witnessed recently.",
  "What's a secret someone told you that you're dying to share (but won't)?",
  "What's the pettiest thing you've gotten upset about?",
  "If you had to describe your friend group's dynamic as a reality show, what would it be called?",
];

const List<String> lateNightTalks = [
  "What's been occupying your mind the most lately?",
  "If you weren't in your current job/field, what would you be doing?",
  "What's a skill you wish you had?",
  "Describe your ideal 'perfect day'.",
  "What's something you learned about yourself recently?",
];

const List<String> forSoulmates = [
  "What fear are you most hesitant to share with me?",
  "In what ways do you feel we complement each other?",
  "Describe a moment you felt completely understood by me.",
  "What does 'unconditional love' look like in our relationship?",
  "What vulnerability are you working on embracing?",
];

// --- Add placeholder questions for the remaining packs similarly ---
const List<String> juicyConvos = [
  "What's your opinion on 'the one that got away'?",
  "Red flag or dealbreaker: Constant jealousy?",
  "Have you ever checked an ex's social media? Be honest.",
  "What's the most surprising thing you learned from a past relationship?",
  "Is it ever okay to stay friends with an ex?",
];
const List<String> forBestFriends = [
  "What's my most annoying habit?",
  "If I were an animal, what would I be?",
  "What's a secret you've never told me?",
  "Describe our friendship in three words.",
  "What's your favorite memory of us?",
];
const List<String> coupleTherapy = [
  "What unmet need do you have in this relationship?",
  "How can we improve our communication during disagreements?",
  "What past hurt still affects how you interact with me?",
  "Describe a time you felt misunderstood by me.",
  "What does 'security' mean to you in a relationship?",
];
const List<String> confessions = [
  "What's a white lie you told recently?",
  "What's something you pretend to like but secretly don't?",
  "What's the most embarrassing thing you've done in the past month?",
  "What's a secret habit you have?",
  "Have you ever snooped where you shouldn't have?",
];
const List<String> gettingToKnow = [
  "What's your go-to comfort movie or TV show?",
  "What's something you're passionate about?",
  "What's your biggest pet peeve?",
  "Are you a morning person or a night owl?",
  "What's one thing on your bucket list?",
];
const List<String> forLongDistance = [
  "What do you miss most about physically being together?",
  "Describe your current surroundings in detail.",
  "What's the first thing you want to do when we see each other next?",
  "How can we make our virtual dates more special?",
  "Share a photo of something that made you think of me today.",
];
const List<String> spicyQuestions = [
  "Describe your biggest turn-on.",
  "What's the most adventurous thing you've done?",
  "Dare: Send a risky text to someone (not present!).",
  "What's a fantasy you've never told anyone?",
  "Dare: Describe your favorite physical feature of the person to your left.",
]; // Note: Dares need different handling
const List<String> forSiblings = [
  "What's your earliest memory of me?",
  "What's something our parents don't know we did?",
  "What's one thing you admire about me?",
  "What's the biggest fight we ever had?",
  "If you could borrow one thing of mine permanently, what would it be?",
];
const List<String> naughtyQuestions = [
  "What's your favorite position?",
  "Describe your ideal romantic evening leading up to intimacy.",
  "What's something new you'd like to try in the bedroom?",
  "Rate your partner's kissing skills (1-10).",
  "What's the most unexpected place you've been intimate?",
];
const List<String> wouldYouRather = [
  "Would you rather have super strength or the ability to fly?",
  "Would you rather always be 10 minutes late or 20 minutes early?",
  "Would you rather give up cheese or coffee forever?",
  "Would you rather explore deep space or the deep ocean?",
  "Would you rather have a rewind button or a pause button for your life?",
];

// --- List of All Packs ---
final List<CardPack> allCardPacks = [
  CardPack(
    id: 'deep',
    name: 'DEEP QUESTIONS',
    description: 'Questions that hit too deep.',
    questions: deepQuestions,
    color: Colors.indigo[300]!,
  ),
  CardPack(
    id: 'couple',
    name: 'COUPLE QUESTIONS',
    description: 'Questions that will leave you feeling closer.',
    questions: coupleQuestions,
    color: Colors.red[300]!,
  ),
  CardPack(
    id: 'tea',
    name: 'SPILL THE TEA',
    description: 'pov: you just had an hour-long gossip session.',
    questions: spillTheTea,
    color: Colors.teal[300]!,
  ),
  CardPack(
    id: 'late_night',
    name: 'LATE NIGHT TALKS',
    description: 'Get to know each other — for real.',
    questions: lateNightTalks,
    color: Colors.deepPurple[300]!,
  ),
  CardPack(
    id: 'soulmates',
    name: 'FOR SOULMATES',
    description: 'Get real and vulnerable and deepen your love.',
    questions: forSoulmates,
    color: Colors.pink[200]!,
  ),
  CardPack(
    id: 'juicy',
    name: 'JUICY CONVOS',
    description: 'All about relationships, cheating, and exes!',
    questions: juicyConvos,
    color: Colors.orange[400]!,
  ),
  CardPack(
    id: 'besties',
    name: 'FOR BEST FRIENDS',
    description: 'How well do you really know them?',
    questions: forBestFriends,
    color: Colors.lightBlue[300]!,
  ),
  CardPack(
    id: 'therapy',
    name: 'COUPLE THERAPY',
    description: 'Deep & rarely-asked questions. Meant to heal.',
    questions: coupleTherapy,
    color: Colors.brown[300]!,
  ),
  CardPack(
    id: 'confessions',
    name: 'CONFESSIONS',
    description: 'Expose your hidden secrets; no one is safe.',
    questions: confessions,
    color: Colors.grey[500]!,
  ),
  CardPack(
    id: 'getting_to_know',
    name: 'GETTING TO KNOW',
    description: 'Questions to meet someone new.',
    questions: gettingToKnow,
    color: Colors.green[300]!,
  ),
  CardPack(
    id: 'long_distance',
    name: 'FOR LONG-DISTANCE',
    description: 'Warning: this will make it difficult to hang up.',
    questions: forLongDistance,
    color: Colors.cyan[300]!,
  ),
  CardPack(
    id: 'spicy',
    name: 'SPICY QUESTIONS',
    description: 'Turn up the heat with – extra risqué dares.',
    questions: spicyQuestions,
    color: Colors.red[600]!,
  ), // Needs dare handling
  CardPack(
    id: 'siblings',
    name: 'FOR SIBLINGS',
    description: 'Ask each other before it’s too late.',
    questions: forSiblings,
    color: Colors.yellow[700]!,
  ),
  CardPack(
    id: 'naughty',
    name: 'NAUGHTY QUESTIONS',
    description: 'Questions for every couple\'s favorite subject.',
    questions: naughtyQuestions,
    color: Colors.purple[400]!,
  ),
  CardPack(
    id: 'wyr',
    name: 'WOULD YOU RATHER',
    description: 'The classic game but much more intense.',
    questions: wouldYouRather,
    color: Colors.lime[600]!,
  ),
];
