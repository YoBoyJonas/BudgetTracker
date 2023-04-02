import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    try{
    if (await Hive.boxExists('money')){
      await Hive.deleteFromDisk();
      await Hive.openBox('money');
    }
    
    } on Exception{print('klaida');}
    
    //deletes all data frome firestore database
    var collection = FirebaseFirestore.instance.collection('income_expense');
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
    //---------------------------------------
  }
}