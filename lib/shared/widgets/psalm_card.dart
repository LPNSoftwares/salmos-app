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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.gold.withValues(alpha: 0.16),
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
              IconButton(
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite
                      ? AppTheme.softGold
                      : Theme.of(context).iconTheme.color,
                  size: 42,
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: Colors.blueGrey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ImageAction(
                asset: 'assets/icons/completed.png',
                tooltip: 'Salmo completo',
                onPressed: onReadFullChapter,
              ),
              _ImageAction(
                asset: 'assets/icons/font_decrease.png',
                tooltip: 'Diminuir letra',
                onPressed: onFontDecrease,
              ),
              _ImageAction(
                asset: 'assets/icons/shared.png',
                tooltip: 'Compartilhar',
                onPressed: onShare,
              ),
              _ImageAction(
                asset: 'assets/icons/font_increase.png',
                tooltip: 'Aumentar letra',
                onPressed: onFontIncrease,
              ),
              _ImageAction(
                asset: 'assets/icons/listen.png',
                tooltip: 'Ouvir',
                onPressed: onListen,
              ),
            ],
          ),
          const Divider(height: 16, color: Colors.blueGrey),
          Text(
            psalm.text,
            textAlign: TextAlign.justify,
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 25 * fontScale,
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageAction extends StatelessWidget {
  const _ImageAction({
    required this.tooltip,
    required this.onPressed,
    this.asset,
  });

  final String? asset;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 1.1,
            child: Image.asset(asset!, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
