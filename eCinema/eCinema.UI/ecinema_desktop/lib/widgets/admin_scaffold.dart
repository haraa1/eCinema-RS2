import 'package:flutter/material.dart';

class AdminScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onMenuTap;

  const AdminScaffold({
    Key? key,
    required this.title,
    required this.body,
    required this.selectedIndex,
    required this.onMenuTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onMenuTap,
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.movie),
                label: Text('Filmovi'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person),
                label: Text('Glumci'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.theater_comedy),
                label: Text('Kina'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.theaters),
                label: Text('Kino sale'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                AppBar(title: Text(title), automaticallyImplyLeading: false),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
