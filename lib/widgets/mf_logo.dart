import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

/// The MasterFabric mark + two-line wordmark, as in the site header.
class MfWordmark extends StatelessWidget {
  const MfWordmark({super.key, this.dark = false});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = dark ? Colors.white : MfColors.slate800;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/images/masterfabric-logo.svg',
          height: 24,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MasterFabric',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: color,
                height: 1.1,
              ),
            ),
            Text(
              'Custom Software Development Studio',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: dark ? MfColors.slate400 : MfColors.slate500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
