import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budget_tracker/globals/globals.dart' as globals;


class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {

String _selectedCategoryType = '';

String selectedExpenseCategory = "0";
String selectedIncomeCategory = "0";

final _monthlyIncomeController = TextEditingController();
int _monthlyIncome = 0;
//current users UID
  final uid = FirebaseAuth.instance.currentUser!.uid;


@override
void initState() {
  super.initState();
  fetchMonthlyIncome();
}

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
            SingleChildScrollView(
              child: Column(       
                children: [
                  //////////////////////////////////////////////////////////////
                  //    ! ČIA (ŠITAME children'e) DEDAME VISUS SETTINGUS !    //
                  //////////////////////////////////////////////////////////////
            
                  // Pirmasis settings button nakinantis duomenu bazes duomenis
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 40, 15, 10),               
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          removeDBData();
                          globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(7.0),
                          decoration: BoxDecoration(
                            color: globals.selectedWidgetColor,
                            borderRadius: BorderRadius.circular(70),
                                    border: Border.all(
                                      width: 3,
                                      color: Colors.brown, style: BorderStyle.solid,
                                    )
                            ),
                          child: const Text('Naikinti duomenų bazės duomenis (laikina)', style: TextStyle(color: Colors.red, letterSpacing: 1.5, fontSize: 15))
                        ),              
                      ),
                    ),
                  ),
            
                  // Antrasis settings buttonas leidziantis isnaikinti išsaugotą kategoriją
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.42,
                          padding: const EdgeInsets.only(left: 10),
                          child: FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance.collection(uid).doc('Categories').collection('Expense_Categories').get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              final categories = snapshot.data?.docs.reversed.toList();
                              final activeCategories = categories?.where((category) => category['status'] == 'Active').toList();
                              return Container(
                                decoration: BoxDecoration(
                                  color: globals.selectedWidgetColor,
                                  borderRadius: BorderRadius.circular(70),
                                          border: Border.all(
                                            width: 3,
                                            color: Colors.brown, style: BorderStyle.solid,
                                          )
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: globals.selectedWidgetColor,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 15, right: 20),
                                    alignment: AlignmentDirectional.center,
                                    child: DropdownButton(
                                      borderRadius: BorderRadius.circular(30.0),
                                      items: [
                                        const DropdownMenuItem(
                                          value: "0",
                                          child: Text("Pasirinkti",
                                            style: TextStyle(color: Colors.red,letterSpacing: 0.25,fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        ...?activeCategories
                                          ?.map((category) => DropdownMenuItem(
                                            value: category.id,
                                            child: Text(category['category'].toString().toUpperCase(),
                                              style: const TextStyle(color: Colors.red,letterSpacing: 0.25,fontWeight: FontWeight.bold),
                                            ),
                                          ))
                                          .toList(),
                                      ],
                                      onChanged: (categoryValue) async {
                                        globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                                        setState(() {
                                          selectedExpenseCategory = categoryValue as String;
                                          _selectedCategoryType = 'Expense_Categories';
                                        });
                                      },
                                      value: selectedExpenseCategory,
                                      isExpanded: true,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            
            
                        IconButton(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          onPressed: (){
                            globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                            var collection = FirebaseFirestore.instance.collection(uid).doc('Categories').collection(_selectedCategoryType);
                            String selectedCategory = '';
                            if (selectedExpenseCategory != "0"){
                              collection.doc(selectedExpenseCategory).update({
                                'status': 'deleted'
                              }).then((value){
                                setState(() {                    
                                  selectedExpenseCategory = "0";
                                });
                              });
                            }
                            else{
                              collection.doc(selectedIncomeCategory).update({
                                'status': 'deleted'
                              }).then((value){
                                setState(() {                    
                                  selectedIncomeCategory = "0";
                                });
                              });
                            }
                          },
                          icon: Icon(Icons.delete, color: globals.selectedWidgetColor),
                        ),
            
            
                        Container(
                          width: MediaQuery.of(context).size.width * 0.41,
                          padding: const EdgeInsets.only(right: 10),
                          child: FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance.collection(uid).doc('Categories').collection('Income_Categories').get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              final categories = snapshot.data?.docs.reversed.toList();
                              final activeCategories = categories?.where((category) => category['status'] == 'Active').toList();
                              return Container(
                                decoration: BoxDecoration(
                                  color: globals.selectedWidgetColor,
                                  borderRadius: BorderRadius.circular(70),
                                          border: Border.all(
                                            width: 3,
                                            color: Colors.brown, style: BorderStyle.solid,
                                          )
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: globals.selectedWidgetColor,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 15, right: 20),
                                    alignment: AlignmentDirectional.center,
                                    child: DropdownButton(
                                      borderRadius: BorderRadius.circular(30.0),
                                      items: [
                                        const DropdownMenuItem(
                                          value: "0",
                                          child: Text("Pasirinkti",
                                            style: TextStyle(color: Colors.green,letterSpacing: 0.25,fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        ...?activeCategories
                                          ?.map((category) => DropdownMenuItem(
                                            value: category.id,
                                            child: Text(category['category'].toString().toUpperCase(),
                                              style: const TextStyle(color: Colors.green,letterSpacing: 0.25,fontWeight: FontWeight.bold),
                                            ),
                                          ))
                                          .toList(),
                                      ],
                                      onChanged: (categoryValue) async {
                                        globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                                        setState(() {
                                          selectedIncomeCategory = categoryValue as String;
                                          _selectedCategoryType = 'Income_Categories';
                                        });
                                      },
                                      value: selectedIncomeCategory,
                                      isExpanded: true,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                  ),   
                
                // Šis SizedBox skiria anksčiau esantį setting'ą nuo sekančio setting'o, kad nesusilietų widget'ai
                const SizedBox(height: 10,),
            
                // Trečiasis setting'as susijęs su background pasirinkimu ir dropdown listu su background option'ais
                Container(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  decoration: BoxDecoration(
                    color: globals.selectedWidgetColor,
                    borderRadius: BorderRadius.circular(70),
                      border: Border.all(
                        width: 3,
                        color: Colors.brown, style: BorderStyle.solid,
                      )
                    ),
                  child: Theme(
                    data: Theme.of(context).copyWith(canvasColor: globals.selectedWidgetColor),                  
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
                                globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                                setState(() {
                                  globals.selected = value!;
                                  globals.backgroundIndex = globals.identities.indexOf(value);
                                });
                              },
                            ),
                    ),
                  ),
                ),
            
                // Garso setting   
                Container(
                  margin: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0),
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  decoration: BoxDecoration(
                    color: globals.selectedWidgetColor,
                      borderRadius: BorderRadius.circular(70),
                        border: Border.all(
                          width: 3,
                          color: Colors.brown, style: BorderStyle.solid,
                        )
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(canvasColor: globals.selectedWidgetColor),
                        child: ListTile(
                        title: const Text("Įjungti garsą", style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                          trailing: Switch(
                            value: globals.soundEnabled,
                            onChanged: (bool value) {
                              setState(() {
                                globals.soundEnabled = value;
                              });
                            },
                          ),
                      )
                    )
                  ),
            
                  // Carry over surplus money setting
                  Container(
                    margin: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0),
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    decoration: BoxDecoration(
                      color: globals.selectedWidgetColor,
                        borderRadius: BorderRadius.circular(70),
                          border: Border.all(
                            width: 3,
                            color: Colors.brown, style: BorderStyle.solid,
                          )
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(canvasColor: Colors.amberAccent),
                          child: ListTile(
                          title: const Text("Pinigų perteklių perkelti į kitą mėnesį", style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                            trailing: Switch(
                              value: globals.carryOverSurplusMoney,
                              onChanged: (bool value) {
                                setState(() {
                                  globals.carryOverSurplusMoney = value;
                                });
                              },
                            ),
                        )
                      )
                    ),
            
                    // Add income at start of month setting
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context, 
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Įveskite pajamas'),
                            content: SingleChildScrollView(
                              child: TextFormField(
                                controller: _monthlyIncomeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Skaičius'
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _monthlyIncome = int.tryParse(value) ?? 0;
                                  });
                                },
                                onEditingComplete: () {
                                  _monthlyIncomeController.text = '$_monthlyIncome';
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Įveskite skaičių';
                                  }
                                  final number = int.tryParse(value);
                                  if (number == null) {
                                    return 'Įveskite tinkamą skaičių';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  if (_monthlyIncomeController.text.isNotEmpty &&
                                      int.tryParse(_monthlyIncomeController.text) != null) {
                                    _monthlyIncome = int.parse(_monthlyIncomeController.text);
                                    FirebaseFirestore.instance
                                      .collection(uid)
                                      .doc('monthly_income')
                                      .set({'income': _monthlyIncome});
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text('Išsaugoti'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Atmesti'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                    margin: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0),
                    padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                    decoration: BoxDecoration(
                      color: globals.selectedWidgetColor,
                      borderRadius: BorderRadius.circular(70),
                      border: Border.all(
                        width: 3,
                        color: Colors.brown, 
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Mėnesinės pajamos: ',
                          style: TextStyle(
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Theme(
                            data: Theme.of(context).copyWith(canvasColor: Colors.amberAccent),
                            child: Text(
                              '$_monthlyIncome',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ],
                      ),
            ),

          ],)
        ),

        
      ],)
  );
}

void fetchMonthlyIncome() {
  FirebaseFirestore.instance
      .collection(uid)
      .doc('monthly_income')
      .get()
      .then((snapshot) {
        if (snapshot.exists) {
          _monthlyIncome = snapshot.data()?['income'] ?? 0;
          setState(() {}); // Update the UI to reflect the new value
        }
      });
}


void removeDBData() async{
    
    //deletes almost all data frome firestore database
    
    //---------------------------------------

    var collection = FirebaseFirestore.instance.collection(uid).doc('income_expense').collection('202305income_expense');
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
    //---------------------------------------

    var collection2 = FirebaseFirestore.instance.collection(uid).doc('Categories').collection('Income_Categories');
    var snapshots2 = await collection2.get();
    for (var doc in snapshots2.docs) {
      await doc.reference.delete();
    }
    //---------------------------------------

    var collection3 = FirebaseFirestore.instance.collection(uid).doc('Categories').collection('Expense_Categories');
    var snapshots3 = await collection3.get();
    for (var doc in snapshots3.docs) {
      await doc.reference.delete();
    }
    //---------------------------------------

    var collection4 = FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Balances');
    var snapshots4 = await collection4.get();
    for (var doc in snapshots4.docs) {
      await doc.reference.delete();
    }
    //---------------------------------------

    var collection5 = FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses');
    var snapshots5 = await collection5.get();
    for (var doc in snapshots5.docs) {
      await doc.reference.delete();
    }
    //---------------------------------------
  }
}