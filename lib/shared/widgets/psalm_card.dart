import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/psalm/domain/psalm.dart';
import 'app_background.dart';

class PsalmCard extends StatelessWidget {
  const PsalmCard({
    required this.psalm,
    required this.isFavorite,
    required this.fontScale,
    required this.onFavorite,
    required this.onShare,
    required this.onReadFullChapter,
    required this.onFontDecrease,
    required this.onFontIncrease,
    required this.onListen,
    super.key,
  });

  final Psalm psalm;
  final bool isFavorite;
  final double fontScale;
  final VoidCallback onFavorite;
  final VoidCallback onShare;
  final VoidCallback onReadFullChapter;
  final VoidCallback onFontDecrease;
  final VoidCallback onFontIncrease;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.softGold.withValues(alpha: 0.30),
                      AppTheme.gold.withValues(alpha: 0.10),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      psalm.reference,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      psalm.version.toUpperCase(),
                      style: textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Tooltip(
                message: isFavorite ? 'Remover dos favoritos' : 'Favoritar',
                child: Material(
                  color: isFavorite
                      ? AppTheme.gold.withValues(alpha: 0.16)
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(17),
                  child: IconButton(
                    onPressed: onFavorite,
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite
                          ? AppTheme.gold
                          : Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: Theme.of(context).dividerColor),
          const SizedBox(height: 12),
          Row(
            children: [
              _PsalmAction(
                icon: Icons.menu_book_rounded,
                label: 'Completo',
                onPressed: onReadFullChapter,
              ),
              _PsalmAction(
                icon: Icons.text_decrease_rounded,
                label: 'Menor',
                onPressed: onFontDecrease,
              ),
              _PsalmAction(
                icon: Icons.ios_share_rounded,
                label: 'Enviar',
                onPressed: onShare,
              ),
              _PsalmAction(
                icon: Icons.text_increase_rounded,
                label: 'Maior',
                onPressed: onFontIncrease,
              ),
              _PsalmAction(
                icon: Icons.headphones_rounded,
                label: 'Ouvir',
                onPressed: onListen,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Theme.of(context).dividerColor),
          const SizedBox(height: 18),
          Text(
            psalm.text,
            textAlign: TextAlign.start,
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 24 * fontScale,
              height: 1.35,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PsalmAction extends StatelessWidget {
  const _PsalmAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, size: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
