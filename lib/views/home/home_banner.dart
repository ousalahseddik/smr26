// lib/views/home/home_banner.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/app_theme_model.dart';
import '../../utils/responsive.dart';
import 'badge_detail_view.dart';

class HomeBanner extends StatelessWidget {
  final AppThemeModel theme;

  const HomeBanner({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (theme.bannerState != 'visible') return const SizedBox.shrink();

    final double maxBannerHeight = isTablet(context) ? 280 : 200;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: theme.cardBgColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxBannerHeight),
          child: Stack(
            children: [
            // IMAGE DE FOND — CachedNetworkImage pour affichage offline
            if (theme.bannerPictureUrl != null)
              CachedNetworkImage(
                imageUrl: theme.bannerPictureUrl!,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                placeholder: (context, url) => Container(
                  height: 160,
                  color: theme.headerBg.withValues(alpha: 0.08),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 160,
                  color: theme.headerBg.withValues(alpha: 0.08),
                ),
              ),

            // BOUTON DÉCOUVRIR CLIQUABLE
            if (theme.bannerBtnState == 'visible')
              Positioned(
                top: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BadgeDetailView(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.bannerBtnColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      theme.bannerBtnText.isNotEmpty
                          ? theme.bannerBtnText
                          : 'Voir',
                      style: TextStyle(
                        color: theme.bannerBtnTextColor,
                        fontWeight: FontWeight.w900,
                        fontSize: rFs(context, 13),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
