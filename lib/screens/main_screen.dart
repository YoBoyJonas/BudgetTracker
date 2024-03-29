import 'package:budget_tracker/screens/profile_tab.dart';
import 'package:budget_tracker/screens/settings_tab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:budget_tracker/screens/Home_tab.dart';
import 'package:budget_tracker/screens/add_tab.dart';
import 'package:budget_tracker/screens/statistics_screen.dart';
import 'package:budget_tracker/globals/globals.dart' as globals;
import 'package:provider/provider.dart';

import '../background_provider.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  
  var currentIndex = 0;
  ImageProvider? backgroundImage;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final BackgroundProvider _backgroundProvider = BackgroundProvider();

  @override
  void initState() {
    super.initState();
    loadBackgroundImage();
    loadWidgetColor();
    loadSoundOption();
  }

  void loadBackgroundImage() async {
  var bgDoc = await FirebaseFirestore.instance.collection(uid).doc('Settings').get();
  if (!bgDoc.exists) {
    setState(() {
      globals.selected = globals.identities[0];
      backgroundImage = globals.bg[0];
    });

    // Update the background image in the provider
    Provider.of<BackgroundProvider>(context, listen: false).updateBackgroundImage(backgroundImage!);

    return;
  }

  var bgName = bgDoc.data()!['background'] as String?;
  if (bgName != null) {
    var bgIndex = globals.identities.indexOf(bgName);

    if (bgIndex >= 0 && bgIndex < globals.bg.length) {
      setState(() {
        globals.selected = bgName;
        globals.backgroundIndex = bgIndex;
        backgroundImage = globals.bg[bgIndex];
      });

      // Update the background image in the provider
      Provider.of<BackgroundProvider>(context, listen: false).updateBackgroundImage(backgroundImage!);
    } else {
      // Set a fallback image if the specified background name is not found
      setState(() {
        backgroundImage = globals.bg[0];
      });

      // Update the background image in the provider
      Provider.of<BackgroundProvider>(context, listen: false).updateBackgroundImage(backgroundImage!);
    }
  } else {
    // Handle the case when the value is null
    setState(() {
      globals.selected = globals.identities[0];
      backgroundImage = globals.bg[0];
    });

    // Update the background image in the provider
    Provider.of<BackgroundProvider>(context, listen: false).updateBackgroundImage(backgroundImage!);
  }
}


  void loadWidgetColor() async {
  var bgDoc = await FirebaseFirestore.instance.collection(uid).doc('Settings').get();
  if (!bgDoc.exists) {
    setState(() {
      globals.selectedWidgetColor = globals.selectedWidgetColorList[0];
    });

    // Update the widget color in the provider
    Provider.of<BackgroundProvider>(context, listen: false).updateWidgetColor(globals.selectedWidgetColor);

    return;
  }

  var bgName = bgDoc.data()!['elementColor'];
  if (bgName != null) {
    var bgIndex = globals.selectedWidgetColorList.indexWhere(
      (color) => color.toString() == bgName.toString(),
    );

    if (bgIndex >= 0 && bgIndex < globals.selectedWidgetColorList.length) {
      setState(() {
        globals.selectedWidgetColor = globals.selectedWidgetColorList[bgIndex];
      });

      // Update the widget color in the provider
      Provider.of<BackgroundProvider>(context, listen: false).updateWidgetColor(globals.selectedWidgetColor);
    } else {
      // Set a fallback color if the specified color is not found
      setState(() {
        globals.selectedWidgetColor = globals.selectedWidgetColorList[0];
      });

      // Update the widget color in the provider
      Provider.of<BackgroundProvider>(context, listen: false).updateWidgetColor(globals.selectedWidgetColor);
    }
  } else {
    // Handle the case when the value is null
    setState(() {
      globals.selectedWidgetColor = globals.selectedWidgetColorList[0];
    });

    // Update the widget color in the provider
    Provider.of<BackgroundProvider>(context, listen: false).updateWidgetColor(globals.selectedWidgetColor);
  }
}


  void loadSoundOption() async {
  var bgDoc = await FirebaseFirestore.instance.collection(uid).doc('Settings').get();
  if (!bgDoc.exists){
    setState(() {
      globals.soundEnabled = true;
    });
    return;
  }
  var bgName = bgDoc.data()!['hasSound'];
  if (bgName != null && bgName is bool) {
    setState(() {
      globals.soundEnabled = bgName;
    });

    // Update the sound option in the provider
    Provider.of<BackgroundProvider>(context, listen: false).updateSound(globals.soundEnabled);
  } else {
    // Handle the case when the value is null or not of type bool
    setState(() {
      globals.soundEnabled = true; // Set a fallback value
    });

    // Update the sound option in the provider
    Provider.of<BackgroundProvider>(context, listen: false).updateSound(globals.soundEnabled);
  }
}

  Widget buildTabContent(int index) {
  switch (index) {
    case 0:
      return const HomeTab();
    case 1:
      return const StatisticsScreen();
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
    return ChangeNotifierProvider.value(
      value: _backgroundProvider,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            if (backgroundImage != null)          
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: backgroundImage!, fit: BoxFit.cover)
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
              globals.audioPlayer.playSoundEffect(globals.SoundEffect.tabTransition);
              setState(() {
                currentIndex = index;
              });
            }),
      ),
    );
  }
}

