import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:budget_tracker/globals/globals.dart' as globals;


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
    home: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
          image: DecorationImage(image: globals.bg[globals.backgroundIndex], fit: BoxFit.cover)
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          
          
          body: Stack(
            children: [
            Column(       
              children: [
                //////////////////////////////////////////////////////////////
                //    ! ČIA (ŠITAME children'e) DEDAME VISUS SETTINGUS !    //
                //////////////////////////////////////////////////////////////

                // Pirmasis settings button nakinantis duomenu bazes duomenis
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 40, 15, 10),               
                  child: Center(
                    child: TextButton(
                      onPressed: removeDBData,
                      child: Container(
                        padding: const EdgeInsets.all(7.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          color: Colors.amberAccent,
                          ),
                        child: const Text('Naikinti duomenų bazės duomenis (laikina)', style: TextStyle(color: Colors.red, letterSpacing: 1.5, fontSize: 16))
                      ),              
                    ),
                  ),
                ),

                // Antrasis settings buttonas leidziantis isnaikinti išsaugotą kategoriją
                Container(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Row(
                    children: [
                      Flexible(
                        child: 
                          Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.0), color: Colors.amberAccent),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                canvasColor: Colors.amberAccent,
                              ),
                              child: Container(
                                padding: const EdgeInsets.only(left: 15, right: 20),
                                alignment: AlignmentDirectional.center,
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
                                        child: Text('Pasirinkti', style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
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
                                                      overflow: TextOverflow.ellipsis,
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
                                                          overflow: TextOverflow.ellipsis,
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
                                      borderRadius: BorderRadius.circular(30.0),
                                      items: incomeExpenseCategories,
                                      onChanged: (categoryValue) async{
                                            
                                        setState(() {
                                          selectedCategory = categoryValue;
                                        });
                                      },
                                    value: selectedCategory,
                                    isExpanded: true,
                                    );
                                    }
                                                    
                                                    
                                ),
                              ),
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
                      icon: const Icon(Icons.delete, color: Colors.amberAccent,),
                    )
                  ],
                ),
                ),   
              
              // Šis SizedBox skiria anksčiau esantį setting'ą nuo sekančio setting'o, kad nesusilietų widget'ai
              const SizedBox(height: 40,),

              // Trečiasis setting'as susijęs su background pasirinkimu ir dropdown listu su background option'ais
              Container(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.0), color: Colors.amberAccent),
                child: Theme(
                  data: Theme.of(context).copyWith(canvasColor: Colors.amberAccent),                  
                  child: ButtonTheme(
                      child: DropdownButton(
                        borderRadius: BorderRadius.circular(30.0),
                            items: globals.identities.map((String identity) {
                              return DropdownMenuItem<String>(
                                value: identity,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 40, right: 40),
                                  
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Fonas', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 20),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: ' $identity '.toUpperCase(), style: TextStyle(color: globals.identityColors[globals.identities.indexOf(identity)], fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 1.2),
                                          
                                        ),
                                        const TextSpan(
                                          text: 'plytos', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 20),
                                        )
                                      ]
                                      ),
                                    ),

                                ),    
                              );
                            }).toList(),
                            value: globals.selected,
                            onChanged: (value) {
                              setState(() {
                                globals.selected = value!;
                                globals.backgroundIndex = globals.identities.indexOf(value);
                              });
                            },
                          ),
                  ),
                ),
              ),    
              ],
          ),
                    
          ],)
        ),

        
      ],)
  );
}
void removeDBData() async{
    try{
    if (await Hive.boxExists('money')){
      await Hive.deleteFromDisk();
      await Hive.openBox('money');
    }
    
    } on Exception{if (kDebugMode) {
      print('klaida');
    }}
    
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