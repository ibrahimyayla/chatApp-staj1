import 'package:flutter/cupertino.dart';
import 'package:chat_app/app/CustomTabBar.dart';
import 'package:chat_app/app/CustomTabScaffold.dart';
import 'package:chat_app/app/tab_items.dart';

class MyCustomBottomNavigation extends StatelessWidget {
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectedTab;
  final Map<TabItem, Widget> sayfaOlusturucu;
  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys;

  ///note : bottom navigator gizlemek istediğinde
  ///Navigator.of(context,rootNavigator: true)....

  const MyCustomBottomNavigation(
      {Key key,
      @required this.currentTab,
      @required this.onSelectedTab,
      @required this.sayfaOlusturucu,
      @required this.navigatorKeys})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCupertinoTabScaffold(
        tabBar: CustomCupertinoTabBar(
          items: [
            _navItemOlustur(TabItem.Konusmalarim),
            _navItemOlustur(TabItem.Profil)
          ],
          onTap: (index) => onSelectedTab(TabItem.values[index]),
          // fontSize: 50.0,
          tabbarHeight: 50.0,
          // iconSize: 40.0,
        ),
        tabBuilder: (context, index) {
          final gosterilecekItem = TabItem.values[index];
          return CupertinoTabView(
              navigatorKey: navigatorKeys[gosterilecekItem],
              builder: (context) {
                print(sayfaOlusturucu[gosterilecekItem]);
                return sayfaOlusturucu[gosterilecekItem];
              });
        });

  }

  BottomNavigationBarItem _navItemOlustur(TabItem tabItem) {
    final olusturulacakTab = TabItemData.tumTablar[tabItem];

    return BottomNavigationBarItem(
      icon: Icon(olusturulacakTab.icon),
      label: olusturulacakTab.label,
    );
  }
}
