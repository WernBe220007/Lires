import 'package:flutter/material.dart';
import 'package:lires/structures/priveleges.dart';

class ClientNavigation extends StatefulWidget {
  final privelege = Priveleges.admin;
  const ClientNavigation({super.key});

  @override
  ClientNavigationState createState() => ClientNavigationState();
}

class ClientNavigationState extends State<ClientNavigation> {
  int currentIndex = 0;

  @override
  void initState() {
    currentIndex = widget.privelege == Priveleges.student ? 1 : 0;
    super.initState();
  }

  final screens = [
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
    const Placeholder()
  ];

  final screensStudnets = [
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
  ];

  final List<BottomNavigationBarItem> admin = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Übersicht',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.room_outlined),
      activeIcon: Icon(Icons.room),
      label: 'Reservierung',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.notifications_outlined),
      activeIcon: Icon(Icons.notifications),
      label: 'Anfragen',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings),
      label: 'Einstellungen',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.manage_accounts_outlined),
      activeIcon: Icon(Icons.manage_accounts),
      label: 'System',
    ),
  ];

  final List<BottomNavigationBarItem> av = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Übersicht',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.room_outlined),
      activeIcon: Icon(Icons.room),
      label: 'Reservierung',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.notifications_outlined),
      activeIcon: Icon(Icons.notifications),
      label: 'Anfragen',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings),
      label: 'Einstellungen',
    ),
  ];

  final List<BottomNavigationBarItem> teacher = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Übersicht',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.room_outlined),
      activeIcon: Icon(Icons.room),
      label: 'Reservierung',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.notifications_outlined),
      activeIcon: Icon(Icons.notifications),
      label: 'Anfragen',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings),
      label: 'Einstellungen',
    ),
  ];

  final List<BottomNavigationBarItem> student = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.notifications_outlined),
      activeIcon: Icon(Icons.notifications),
      label: 'Anfragen',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Übersicht',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings),
      label: 'Einstellungen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: widget.privelege == Priveleges.student
            ? screensStudnets[currentIndex]
            : screens[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (value) => setState(() => currentIndex = value),
          items: widget.privelege == Priveleges.admin
              ? admin
              : widget.privelege == Priveleges.av
                  ? av
                  : widget.privelege == Priveleges.teacher
                      ? teacher
                      : student,
        ));
  }
}
