
import 'package:flutter/material.dart';
import 'package:budget_tracker/screens/Home_tab.dart';

class MainScreen extends StatefulWidget{
  const MainScreen ({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>{
  var currentIndex = 0;
  Widget buildTabContent(int index){
    switch(index){
      case 0:
        return const HomeTab();
      case 1: return Container();
      case 2: return Container();
      case 3: return Container();
      default: 
        return const HomeTab(); 
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildTabContent(currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>
        [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Pagrindinis'),
        BottomNavigationBarItem(icon: Icon(Icons.query_stats), label: 'Statistika'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Nustatymai'),  
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profilis'),  
        ], 
        currentIndex: currentIndex,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.black,
        onTap: (index){
          setState(() {
            	currentIndex = index;
          });
        }
        ),
      );
  }
}