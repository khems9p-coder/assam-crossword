import 'package:material_ui/material_ui.dart';

class Topic {
  final String id;
  final String name;

  const Topic(this.id, this.name);
}

class SubjectArea {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<Topic> topics;

  const SubjectArea({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.topics,
  });
}

class CategoryData {
  CategoryData._();

  static const List<SubjectArea> areas = [
    SubjectArea(
      id: 'assam',
      name: 'Assam General Knowledge',
      description:
          'Geography, history, culture, people, festivals, tribes, temples and more.',
      icon: Icons.landscape_rounded,
      topics: [
        Topic('assam_geography', 'Assam Geography'),
        Topic('assam_history', 'Assam History'),
        Topic('assam_culture', 'Assam Culture'),
        Topic('assam_wildlife', 'Birds and Animals'),
        Topic('assam_economy', 'Assam Economy'),
        Topic('assam_administration', 'Assam Administration'),
        Topic('assam_literature', 'Literature and Language'),
        Topic('assam_festivals', 'Festivals and Fairs'),
        Topic('assam_people', 'Famous Assamese People'),
        Topic('assam_tribes', 'Tribes and Communities'),
        Topic('assam_temples', 'Temples and Monuments'),
      ],
    ),
    SubjectArea(
      id: 'india',
      name: 'India General Knowledge',
      description:
          'Geography, history, polity, economy, culture and science of India.',
      icon: Icons.flag_rounded,
      topics: [
        Topic('india_geography', 'Indian Geography'),
        Topic('india_history', 'Indian History'),
        Topic('india_freedom', 'Indian Freedom Movement'),
        Topic('india_constitution', 'Indian Constitution'),
        Topic('india_polity', 'Indian Polity'),
        Topic('india_economy', 'Indian Economy'),
        Topic('india_culture', 'Indian Culture'),
        Topic('india_states', 'States and Capitals'),
        Topic('india_rivers_mountains', 'Rivers and Mountains'),
        Topic('india_wildlife', 'National Parks and Wildlife'),
        Topic('india_personalities', 'Important Personalities'),
        Topic('india_science', 'Science and Technology'),
        Topic('india_institutions', 'National Institutions'),
      ],
    ),
    SubjectArea(
      id: 'english',
      name: 'General English Vocabulary',
      description: 'Synonyms, antonyms, idioms, spelling and exam vocabulary.',
      icon: Icons.menu_book_rounded,
      topics: [
        Topic('eng_synonyms', 'Synonyms'),
        Topic('eng_antonyms', 'Antonyms'),
        Topic('eng_one_word', 'One-Word Substitutions'),
        Topic('eng_idioms', 'Idioms and Phrases'),
        Topic('eng_confused', 'Commonly Confused Words'),
        Topic('eng_exam', 'Exam Vocabulary'),
        Topic('eng_spelling', 'Spelling'),
        Topic('eng_advanced', 'Advanced Vocabulary'),
        Topic('eng_literary', 'Literary Vocabulary'),
        Topic('eng_newspaper', 'Newspaper Vocabulary'),
      ],
    ),
  ];

  static Topic? findTopic(String id) {
    for (final SubjectArea area in areas) {
      for (final Topic topic in area.topics) {
        if (topic.id == id) {
          return topic;
        }
      }
    }
    return null;
  }
}
