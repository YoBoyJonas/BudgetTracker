import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

    @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  String selectedCategory = "0";

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

              Container(
                padding: EdgeInsets.only(left: 40.0),
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    Flexible(
                      child: 
                        Container(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('income_expense').snapshots(),
              
                              builder: (context, snapshot) {
                              List<DropdownMenuItem> incomeExpenseCategories = [];
              
                              if (!snapshot.hasData){
                                const CircularProgressIndicator();
                              }
                              else {
                                final categories = snapshot.data?.docs.reversed.toList();

                                incomeExpenseCategories.add(const DropdownMenuItem(
                                  value: "0",
                                  child: Text('Pasirinkti'),
                                ));
              
                                for(var category in categories!){
                                  var nameText = category['name'].toString().toUpperCase();
                                  int counter =0;
                                    for(var income in incomeExpenseCategories){

                                      if ((income.child as Text).data!.toLowerCase == category['name'].toLowerCase()){break;}
                                      else if ((income.child as Text).data!.toLowerCase() != category['name'].toLowerCase()){counter++;}

                                      if (counter == incomeExpenseCategories.length){
                                        if (category['type'] == "Income"){
                                          incomeExpenseCategories.add(
                                            DropdownMenuItem(
                                              value: category.id,
                                              child: Text(
                                                nameText,
                                                style: const TextStyle(color: Colors.green, letterSpacing: 0.25, fontWeight: FontWeight.bold),
                                              )                        
                                            )  
                                          );
                                          break;
                                        }
                                        else{
                                          incomeExpenseCategories.add(
                                                DropdownMenuItem(
                                                  value: category.id,
                                                  child: Text(
                                                    nameText,
                                                    style: const TextStyle(color: Colors.red, letterSpacing: 0.25, fontWeight: FontWeight.bold),
                                                  )                        
                                                )  
                                              );
                                              break;
                                        }

                                      }                          
                                }         
                              }
                              }
                                return DropdownButton(
                                items: incomeExpenseCategories,
                                onChanged: (categoryValue) async{
              
                                  setState(() {
                                    selectedCategory = categoryValue;
                                  });
                                },
                              value: selectedCategory,
                              isExpanded: false,
                              );
                      }
                      
                      
                      )
              
                    )),

                    IconButton(
                      onPressed: (){
                        var collection = FirebaseFirestore.instance.collection('income_expense');
                        collection
                          .doc(selectedCategory)
                          .delete();

                          selectedCategory = "0";
                      },
                      icon: const Icon(Icons.delete),
                    )
                  ],
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

    var collection2 = FirebaseFirestore.instance.collection('income_categories');
    var snapshots2 = await collection2.get();
    for (var doc in snapshots2.docs) {
      await doc.reference.delete();
    }
    //---------------------------------------
  }
}