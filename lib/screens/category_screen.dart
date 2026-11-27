import 'package:material_ui/material_ui.dart';

import '../data/category_data.dart';
import '../data/question_bank.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/app_routes.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = AppState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final String? selectedId = state.topicId;

        return Scaffold(
          appBar: AppBar(title: const Text('Select Category')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Choose a subject area, then pick a topic.',
                style: TextStyle(fontSize: 15, color: AppColors.grey),
              ),
              const SizedBox(height: 12),
              for (final SubjectArea area in CategoryData.areas)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      initiallyExpanded:
                          area.topics.any((t) => t.id == selectedId),
                      shape: const Border(),
                      collapsedShape: const Border(),
                      leading: Icon(
                        area.icon,
                        color: AppColors.forestGreen,
                        size: 32,
                      ),
                      title: Text(
                        area.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(area.description),
                      children: [
                        for (final Topic topic in area.topics)
                          ListTile(
                            title: Text(topic.name),
                            subtitle: QuestionBank.instance.hasPuzzles(topic.id)
                                ? null
                                : const Text('Puzzles coming soon'),
                            selected: topic.id == selectedId,
                            selectedColor: AppColors.forestGreen,
                            trailing: Icon(
                              topic.id == selectedId
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked,
                              color: topic.id == selectedId
                                  ? AppColors.forestGreen
                                  : AppColors.grey,
                            ),
                            onTap: () => state.selectTopic(topic.id),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: selectedId == null
                    ? null
                    : () => Navigator.of(context)
                        .pushNamed(AppRoutes.difficulty),
                child: const Text('Next: Choose Difficulty'),
              ),
            ),
          ),
        );
      },
    );
  }
}
