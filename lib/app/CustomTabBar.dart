import 'dart:ui' show ImageFilter;


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


const double _kTabBarHeight = 50.0;

const Color _kDefaultTabBarBorderColor = CupertinoDynamicColor.withBrightness(
  color: CupertinoColors.inactiveGray,
  darkColor: CupertinoColors.inactiveGray,
);
const Color _kDefaultTabBarInactiveColor = CupertinoColors.inactiveGray;

class CustomCupertinoTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  CustomCupertinoTabBar({
    Key key,
    @required this.items,
    this.onTap,
    this.currentIndex = 0,
    this.backgroundColor,
    this.activeColor,
    this.isVisible = true,
    this.inactiveColor = _kDefaultTabBarInactiveColor,
    this.iconSize = 30.0,
    @required this.tabbarHeight,
    // this.fontSize = 10.0,
    this.fontSize,
    this.border = const Border(
      top: BorderSide(
        color: _kDefaultTabBarBorderColor,
        width: 0.0, // One physical pixel.
        style: BorderStyle.solid,
      ),
    ),
  })  : assert(items != null),
        assert(tabbarHeight != null),
        assert(
        items.length >= 2,
        "Tabs need at least 2 items to conform to Apple's HIG",
        ),
        assert(currentIndex != null),
        assert(0 <= currentIndex && currentIndex < items.length,
        "$currentIndex ${items.length}  uzunlukta hata",),
        assert(iconSize != null),
        assert(inactiveColor != null),
        super(key: key){
    // print(this.tabbarHeight);
  }

  List<BottomNavigationBarItem> items;

  final ValueChanged<int> onTap;

  final int currentIndex;

  final bool isVisible;

  final Color backgroundColor;

  final Color activeColor;

  final Color inactiveColor;

  final double iconSize;

  final Border border;

  final double tabbarHeight;

  final double fontSize;

  @override
  Size get preferredSize => const Size.fromHeight(0.0);

/*
  @override
  Size get preferredSize => const Size.fromHeight(80.0);*/

  bool opaque(BuildContext context) {
    final Color backgroundColor =
        this.backgroundColor ?? CupertinoTheme.of(context).barBackgroundColor;
    return CupertinoDynamicColor.resolve(backgroundColor, context).alpha ==
        0xFF;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    final Color backgroundColor = CupertinoDynamicColor.resolve(
      this.backgroundColor ?? CupertinoTheme.of(context).barBackgroundColor,
      context,
    );

    BorderSide resolveBorderSide(BorderSide side) {
      return side == BorderSide.none
          ? side
          : side.copyWith(
          color: CupertinoDynamicColor.resolve(side.color, context));
    }

    // Return the border as is when it's a subclass.
    final Border resolvedBorder = border == null || border.runtimeType != Border
        ? border
        : Border(
      top: resolveBorderSide(border.top),
      left: resolveBorderSide(border.left),
      bottom: resolveBorderSide(border.bottom),
      right: resolveBorderSide(border.right),
    );

    final Color inactive =
    CupertinoDynamicColor.resolve(inactiveColor, context);
    Widget result = DecoratedBox(
      decoration: BoxDecoration(
        border: resolvedBorder,

        /// note : tabbar arkaplan ayarlanması
        color: backgroundColor,
      ),
      child: SizedBox(
        height: tabbarHeight + bottomPadding,
        child: IconTheme.merge(
          // Default with the inactive state.
          data: IconThemeData(color: inactive, size: iconSize),
          child: DefaultTextStyle(
            // Default with the inactive state.
            style: CupertinoTheme.of(context)
                .textTheme
                .tabLabelTextStyle
                .copyWith(color: inactive),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: Semantics(
                explicitChildNodes: true,
                child: Row(
                  // Align bottom since we want the labels to be aligned.
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _buildTabItems(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!opaque(context)) {
      // For non-opaque backgrounds, apply a blur effect.
      result = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: result,
        ),
      );
    }

    return result;
  }

  List<Widget> _buildTabItems(BuildContext context) {
    final List<Widget> result = <Widget>[];
    final CupertinoLocalizations localizations =
    CupertinoLocalizations.of(context);

    for (int index = 0; index < items.length; index += 1) {
      final bool active = index == currentIndex;
      result.add(
        _wrapActiveItem(
          context,
          Expanded(
            child: Semantics(
              selected: active,
              hint: localizations.tabSemanticsLabel(
                tabIndex: index + 1,
                tabCount: items.length,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap == null
                    ? null
                    : () {
                  onTap(index);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _buildSingleTabItem(items[index], active),
                ),
              ),
            ),
          ),
          active: active,
        ),
      );
    }

    return result;
  }

  List<Widget> _buildSingleTabItem(BottomNavigationBarItem item, bool active) {
    return <Widget>[
      Flexible(
        flex: 75,
        child: FittedBox(

          child: Container(
            // color: Colors.blue,
            // alignment: Alignment.bottomCenter,
              padding: EdgeInsets.all(4),
              child:active ? item.activeIcon : item.icon
          ),
        ),
      ),
      Flexible(
          flex: 25,
          // fit: FlexFit.tight,
          child: FittedBox(
            child: Container(
              alignment: Alignment.center,
              // color: Colors.red,
              child: Text(
                item.label,

                maxLines: 1,
                softWrap: false,
                // style: TextStyle(fontWeight: FontWeight.bold),
                // overflow: TextOverflow.,
              ),
            ),
          ))
      // child: Text(item.label))),
    ];
  }


  /// Change the active tab item's icon and title colors to active.
  Widget _wrapActiveItem(BuildContext context, Widget item,
      {@required bool active}) {
    // if (!active) return item;   // deprecated

    final Color activeColor = this.activeColor;
    return IconTheme.merge(
      data: IconThemeData(color: activeColor),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: activeColor),
        child: item,
      ),
    );
  }

  /// Create a clone of the current [CustomCupertinoTabBar] but with provided
  /// parameters overridden.
  CustomCupertinoTabBar copyWith({
    Key key,
    List<BottomNavigationBarItem> items,
    Color backgroundColor,
    Color activeColor,
    Color inactiveColor,
    double iconSize,
    Border border,
    int currentIndex,
    ValueChanged<int> onTap,
  }) {
    /// note : tabbar yükseliği ayarlanması
    return CustomCupertinoTabBar(
      key: key ?? this.key,
      items: items ?? this.items,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      // iconSize: Constraints().getConstraints()["TabBarIconSize"],
      // iconSize: iconSize ?? this.iconSize,
      tabbarHeight: this.tabbarHeight,
      border: border ?? this.border,
      currentIndex: currentIndex ?? this.currentIndex,
      onTap: onTap ?? this.onTap,
    );
  }
}