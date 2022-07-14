import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../pages/screens.dart';
import '../widgets/widgets.dart';

class NavScreen extends StatefulWidget {
  @override
  _NavScreenState createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  final List<Widget> _screens = [
    Appointment(),
    Patient(),
    Schedule(),
    Chat(),
  ];
  final List<IconData> _icons = const [
    Icons.more_time, //Appointment
    MdiIcons.accountGroupOutline, // Patients
    Icons.event_available_rounded, // Schedule
    Icons.question_answer_rounded // Chat
  ];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _icons.length,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.only(bottom: 12.0),
          color: Colors.white,
          child: CustomTabBar(
            icons: _icons,
            selectedIndex: _selectedIndex,
            onTap: (index) {
              setState(() => _selectedIndex = index);
              FocusScope.of(context).unfocus();
            },
          ),
        ),
      ),
    );
  }
}
