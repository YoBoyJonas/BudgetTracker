import 'package:budget_tracker/screens/profile_tab.dart';
import 'package:budget_tracker/screens/settings_tab.dart';
import 'package:flutter/material.dart';
import 'package:budget_tracker/screens/Home_tab.dart';
import 'package:budget_tracker/screens/add_tab.dart';

import 'package:budget_tracker/globals/globals.dart' as globals;


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var currentIndex = 0;

  Widget buildTabContent(int index) {
    switch (index) {
      case 0:
        return const HomeTab();
      case 1:
        return Container();
      case 2:
        return const AddTab();
      case 3:
        return const SettingsTab();
      case 4:
        return const ProfileTab();
      default:
        return const HomeTab();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: globals.bg[globals.backgroundIndex], fit: BoxFit.cover)
            ),
          ),
          buildTabContent(currentIndex),
      ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: 'Pagrindinis'),
            BottomNavigationBarItem(
                icon: Icon(Icons.query_stats), label: 'Statistika'),
            BottomNavigationBarItem(
                icon: Icon(Icons.add), label: 'Pridėti'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Nustatymai'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Profilis'),
          ],
          currentIndex: currentIndex,
          selectedItemColor: Colors.amber,
          unselectedItemColor: Colors.black,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          }),
    );
  }
}
