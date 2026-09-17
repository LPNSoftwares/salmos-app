import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../psalm/presentation/app_controller.dart';
import '../../shared/widgets/app_background.dart';
import 'bible_screens.dart';

class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key, this.history = false});
  final bool history;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final items = history ? state.history : state.favorites;
    return BibleShell(
      title: history ? 'Seu caminho de leitura' : 'Palavras para guardar',
      subtitle: history ? 'Histórico' : 'Seus favoritos',
      selected: history ? 0 : 4,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${items.length} leituras ${history ? 'recentes' : 'salvas'}',
                ),
              ),
              if (history)
                TextButton(
                  onPressed: items.isEmpty ? null : state.clearHistory,
                  child: const Text('Limpar histórico'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            GlassCard(
              child: Column(
                children: [
                  Icon(
                    history ? Icons.history : Icons.favorite_outline,
                    size: 48,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    history
                        ? 'Sua próxima leitura começa aqui.'
                        : 'Guarde o que tocar seu coração.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    history
                        ? 'Os trechos abertos aparecem nesta lista.'
                        : 'Toque no coração durante a leitura para salvar um trecho.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          for (final passage in items) ...[
            GlassCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: Icon(history ? Icons.history : Icons.favorite_rounded),
                title: Text(passage.reference),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${passage.text}\n${passage.version.toUpperCase()}',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openReading(context, ref, passage),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
