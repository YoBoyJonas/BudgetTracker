import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 40, 15, 10),               
                child: Center(
                  child: OutlinedButton(
                    onPressed: removeDBData,
                    child: const Text('Naikinti duomenų bazės duomenis (laikina)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, letterSpacing: 1.5))
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void removeDBData() async{
    if (await Hive.boxExists('money')){
      await Hive.deleteFromDisk();
      await Hive.openBox('money');
    }
  }
}