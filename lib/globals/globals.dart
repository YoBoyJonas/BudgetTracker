library globals;

import 'package:flutter/material.dart';

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
