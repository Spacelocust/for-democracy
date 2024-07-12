import 'package:flutter/material.dart';
import 'package:mobile/utils/theme_colors.dart';

class HelldiversListTile extends ListTile {
  const HelldiversListTile({
    super.key,
    super.leading,
    super.title,
    super.subtitle,
    super.trailing,
    super.isThreeLine = false,
    super.dense,
    super.visualDensity,
    super.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(8),
      ),
    ),
    super.style,
    super.selectedColor,
    super.iconColor,
    super.textColor = Colors.black,
    super.titleTextStyle = const TextStyle(
      color: Colors.black,
    ),
    super.subtitleTextStyle,
    super.leadingAndTrailingTextStyle,
    super.contentPadding = const EdgeInsets.only(
      left: 16,
      right: 16,
    ),
    super.enabled = true,
    super.onTap,
    super.onLongPress,
    super.onFocusChange,
    super.mouseCursor,
    super.selected = false,
    super.focusColor,
    super.hoverColor,
    super.splashColor,
    super.focusNode,
    super.autofocus = false,
    super.tileColor = ThemeColors.softPrimary,
    super.selectedTileColor,
    super.enableFeedback,
    super.horizontalTitleGap,
    super.minVerticalPadding,
    super.minLeadingWidth,
    super.titleAlignment,
  }) : assert(!isThreeLine || subtitle != null);
}
