library globals;

import 'package:flutter/material.dart';
import 'package:budget_tracker/audio_player.dart';

//required for backgrounds functionality
int backgroundIndex = 0; // default = 0

List<String> identities =[
  'baltos' , 
  'pilkos',
  'juodos'];

List<Color> identityColors = <Color>[
  Colors.white,
  Colors.grey,
  Colors.black
];

String selected = 'baltos';
List<ImageProvider> bg = [ 
  const AssetImage('assets/images/white.png'),
  const AssetImage('assets/images/grey.png'),
  const AssetImage('assets/images/black.png')
];

//changes all widget color to the selected one
List<Color> selectedWidgetColorList = <Color>[
  const Color.fromARGB(248, 226, 214, 192),
  Colors.amberAccent
];

Color selectedWidgetColor = selectedWidgetColorList[0]; // default = [0]

final Audio audioPlayer = Audio();
enum SoundEffect {
  buttonClick,
  tabTransition
}
bool soundEnabled = true;