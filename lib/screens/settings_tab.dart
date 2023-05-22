import 'package:budget_tracker/screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budget_tracker/globals/globals.dart' as globals;

import '../background_provider.dart';


class SettingsTab extends StatefulWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {

  final List<String> _currencies = [
    "\$",
    "€",
    "£",
    "¥",
  ];

  final List<String> _intervals = [
    "Mėnesinis",
    "Savaitinis",
  ];

String _selectedCategoryType = '';

String selectedExpenseCategory = "0";
String selectedIncomeCategory = "0";

final GlobalKey<FormState> _formKey = GlobalKey();
final _monthlyIncomeController = TextEditingController();
int _monthlyIncome = 0;
//current users UID
  final uid = FirebaseAuth.instance.currentUser!.uid;


@override
void initState() {
  super.initState();
  fetchMonthlyIncome();
}



void updateBackground(String value) async {
    final settingsSnapshot = await FirebaseFirestore.instance.collection(uid).doc('Settings').get();
    if (settingsSnapshot.exists) {
      Map<String, dynamic> data = settingsSnapshot.data()!;
      String bal = data['background'].toString();
      if (bal.isNotEmpty) {
        FirebaseFirestore.instance.collection(uid).doc('Settings').update({'background': value});
      } else {
        FirebaseFirestore.instance.collection(uid).doc('Settings').set({'background': value});
      }
    } else {
      FirebaseFirestore.instance.collection(uid).doc('Settings').set({'background': value});
    }
    Provider.of<BackgroundProvider>(context, listen: false).updateBackgroundImage(globals.bg[globals.backgroundIndex]);

    
  }

void updateElementColor(String value) async{
    final settingsSnapshot = await FirebaseFirestore.instance.collection(uid).doc('Settings').get();
    if (settingsSnapshot.exists) {
      Map<String, dynamic> data = settingsSnapshot.data()!;
      String bal = data['elementColor'].toString();
      if(bal.isNotEmpty){
        FirebaseFirestore.instance.collection(uid).doc('Settings').update({'elementColor' : value});
      }
      else{
        FirebaseFirestore.instance.collection(uid).doc('Settings').set({'elementColor' : value});
      }
    }
    else
    {
      FirebaseFirestore.instance.collection(uid).doc('Settings').set({'elementColor' : value});
    }
    Provider.of<BackgroundProvider>(context, listen: false).updateWidgetColor(globals.selectedWidgetColor);
  }

void updateSound(bool value) async{
    final settingsSnapshot = await FirebaseFirestore.instance.collection(uid).doc('Settings').get();
    if (settingsSnapshot.exists) {
      Map<String, dynamic> data = settingsSnapshot.data()!;
      String bal = data['hasSound'].toString();
      if(bal.isNotEmpty){
        FirebaseFirestore.instance.collection(uid).doc('Settings').update({'hasSound' : value});
      }
      else{
        FirebaseFirestore.instance.collection(uid).doc('Settings').set({'hasSound' : value});
      }
    }
    else
    {
      FirebaseFirestore.instance.collection(uid).doc('Settings').set({'hasSound' : value});
    }

    Provider.of<BackgroundProvider>(context, listen: false).updateSound(globals.soundEnabled);
  }  

@override
Widget build(BuildContext context) {
  final backgroundProvider = Provider.of<BackgroundProvider>(context);
  final backgroundImage = backgroundProvider.backgroundImage;
  return ChangeNotifierProvider(
    create: (_) => BackgroundProvider(),
    child: MaterialApp(
      home: Stack(
        children: [
          if (backgroundImage != null)  
          Container(
            decoration: BoxDecoration(
            image: DecorationImage(image: backgroundImage, fit: BoxFit.cover)
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
                    // Padding(
                    //   padding: const EdgeInsets.fromLTRB(15, 40, 15, 10),               
                    //   child: Center(
                    //     child: TextButton(
                    //       onPressed: () {
                    //         removeDBData();
                    //         globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                    //       },
                    //       child: Container(
                    //         padding: const EdgeInsets.all(7.0),
                    //         decoration: BoxDecoration(
                    //           color: globals.selectedWidgetColor,
                    //           borderRadius: BorderRadius.circular(70),
                    //                   border: Border.all(
                    //                     width: MediaQuery.of(context).size.width * 0.007,
                    //                     color: Colors.brown, style: BorderStyle.solid,
                    //                   )
                    //           ),
                    //         child: const Text('Naikinti duomenų bazės duomenis (laikina)', style: TextStyle(color: Colors.red, letterSpacing: 1.5, fontSize: 15))
                    //       ),              
                    //     ),
                    //   ),
                    // ),
              
                    // Antrasis settings buttonas leidziantis isnaikinti išsaugotą kategoriją
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    Row(
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
                                            width: MediaQuery.of(context).size.width * 0.007,
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
                            // Determine selected category name
                            String categoryName = _selectedCategoryType == 'Expense_Categories'
                              ? selectedExpenseCategory
                              : selectedIncomeCategory;

                              if (categoryName != "0") {
                              collection.doc(categoryName).get().then((snapshot) {
                                if (snapshot.exists) {
                                  // Get snapshot data to display in snackbar which category was deleted
                                  var categoryData = snapshot.data();
                                  String category = categoryData?['category'];
                                  collection.doc(categoryName).update({'status': 'deleted'}).then((value) {
                                    showSnackbar(context, "Sėkmingai panaikinta $category kategorija", const Duration(seconds: 2));
                                    setState(() {
                                      if (_selectedCategoryType == 'Expense_Categories') {
                                        selectedExpenseCategory = "0";
                                      } else {
                                        selectedIncomeCategory = "0";
                                      }
                                    });
                                  }).catchError((error) {
                                    showSnackbar(context, "Nepavyko panaikinti $category kategorijos. $error", const Duration(seconds: 2));
                                  });
                                }
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
                                            width: MediaQuery.of(context).size.width * 0.007,
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
                  
                  // Šis SizedBox skiria anksčiau esantį setting'ą nuo sekančio setting'o, kad nesusilietų widget'ai
                  SizedBox(height: MediaQuery.of(context).size.width * 0.026),
              
                  // Trečiasis setting'as susijęs su background pasirinkimu ir dropdown listu su background option'ais
                  Container(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    decoration: BoxDecoration(
                      color: globals.selectedWidgetColor,
                      borderRadius: BorderRadius.circular(70),
                        border: Border.all(
                          width: MediaQuery.of(context).size.width * 0.007,
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
                                  updateBackground(value.toString());
                                  showSnackbar(context, "Sėkmingai pakeistas fonas į $value plytos", const Duration(seconds: 2));
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
              
                  SizedBox(height: MediaQuery.of(context).size.width * 0.026),
  
                  // setting'as susijęs su widget color selectionu
                  Container(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    decoration: BoxDecoration(
                      color: globals.selectedWidgetColor,
                      borderRadius: BorderRadius.circular(70),
                        border: Border.all(
                          width: MediaQuery.of(context).size.width * 0.007,
                          color: Colors.brown, style: BorderStyle.solid,
                        )
                      ),
                    child: Theme(
                      data: Theme.of(context).copyWith(canvasColor: globals.selectedWidgetColor),                  
                      child: ButtonTheme(
                          child: DropdownButton(
                            borderRadius: BorderRadius.circular(30.0),
                                items: globals.selectedWidgetColorList.map((Color colorDisplay) {
                                  return DropdownMenuItem<Color>(
                                    value: colorDisplay,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 40, right: 40),
                                      
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(70),
                                          border: Border.all(
                                            width: MediaQuery.of(context).size.width * 0.007,
                                            color: Colors.brown, style: BorderStyle.solid,
                                          )
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 15, right: 15),
                                          child: Text('Elementų spalva', style: TextStyle(fontWeight: FontWeight.bold, color: colorDisplay, fontSize: 20,)),
                                        )),
                                    ),    
                                  );
                                }).toList(),
                                value: globals.selectedWidgetColor,
                                onChanged: (value) {
                                  updateElementColor(value.toString());
                                  showSnackbar(context, "Sėkmingas pakeista elementų spalva", const Duration(seconds: 2));
                                  globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                                  setState(() {
                                    globals.selectedWidgetColor = value!;
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
                            width: MediaQuery.of(context).size.width * 0.007,
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
                                updateSound(value);
                                if (value){
                                  showSnackbar(context, "Sėkmingai įjungtas garsas", const Duration(seconds: 1));
                                } else {
                                  showSnackbar(context, "Sėkmingai išjungtas garsas", const Duration(seconds: 1));
                                }
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
                              width: MediaQuery.of(context).size.width * 0.007,
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
                                  updateMoveResidual(value);
                                  if (value){
                                    showSnackbar(context, "Sėkmingai įjungtas pinigų perkėlimas", const Duration(seconds: 1));
                                  } else {
                                    showSnackbar(context, "Sėkmingai išjungtas pinigų perkėlimas", const Duration(seconds: 1));
                                  }
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
                                child: Form(
                                  key: _formKey,
                                  child: TextFormField(
                                    controller: _monthlyIncomeController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Skaičius'
                                    ),
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
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ?? false) {
                                      globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                                      setState(() {
                                        _monthlyIncome = int.parse(_monthlyIncomeController.text);
                                      });
                                      FirebaseFirestore.instance
                                        .collection(uid)
                                        .doc('monthly_income')
                                        .set({'income': _monthlyIncome})
                                        .then((_) {
                                          showSnackbar(context, "Sėkmingai pakeistos pajamos į $_monthlyIncome", const Duration(seconds: 2));
                                        }).catchError((error) {
                                          showSnackbar(context, "Nepavyko pakeist pajamų. $error", const Duration(seconds: 2));
                                        });
  
                                      _monthlyIncomeController.text = '$_monthlyIncome';
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text('Išsaugoti'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                                    _monthlyIncomeController.text = '$_monthlyIncome';
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
                          width: MediaQuery.of(context).size.width * 0.007,
                          color: Colors.brown, 
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Pajamos: ',
                            style: TextStyle(
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width * 0.025),
  
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
                  // Šis SizedBox skiria anksčiau esantį setting'ą nuo sekančio setting'o, kad nesusilietų widget'ai
                  SizedBox(height: MediaQuery.of(context).size.width * 0.026),
              
                  //Setting'as skirtas pakeisti valiutos zenkla
                  Container(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    decoration: BoxDecoration(
                      color: globals.selectedWidgetColor,
                      borderRadius: BorderRadius.circular(70),
                        border: Border.all(
                          width: MediaQuery.of(context).size.width * 0.007,
                          color: Colors.brown, style: BorderStyle.solid,
                        )
                      ),
                    child: Theme(
                      data: Theme.of(context).copyWith(canvasColor: globals.selectedWidgetColor),                  
                      child: ButtonTheme(
                          child: FutureBuilder<String>(
                            future: getCurrencySign(),
                            builder: (context, snapshot) {
                              if(snapshot.hasData){
                              String sign = snapshot.data.toString();
                              return DropdownButton(
                                borderRadius: BorderRadius.circular(30.0),
                                    items: _currencies.map((String identity) {
                                      return DropdownMenuItem<String>(
                                        value: identity,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 40, right: 40),
                                          
                                          child: RichText(
                                            text: TextSpan(
                                              text: 'Valiutos ženklas: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 20),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: ' $identity '.toUpperCase(), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 1.2),
                                                  
                                                ),
                                              ]
                                              ),
                                            ),
                                      
                                        ),    
                                      );
                                    }).toList(),
                                    value: sign,
                                    onChanged: (value) {
                                      globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                                      showSnackbar(context, "Sėkmingai pakeista valiuta į $value", const Duration(seconds: 1));
                                      setState(() {
                                        updateCurrencySign(value.toString());
                                      });
                                    },
                                  );
                              } else {
                                  return const CircularProgressIndicator(); 
                              }
  
                              
                            }
                          ),
                      ),
                    ),
                  ),
                  // Šis SizedBox skiria anksčiau esantį setting'ą nuo sekančio setting'o, kad nesusilietų widget'ai
                  SizedBox(height: MediaQuery.of(context).size.width * 0.026),
              
                  // Setting'as skirtas pasirinkti intervala tarp balanso resetinimo
                  Container(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    decoration: BoxDecoration(
                      color: globals.selectedWidgetColor,
                      borderRadius: BorderRadius.circular(70),
                        border: Border.all(
                          width: MediaQuery.of(context).size.width * 0.007,
                          color: Colors.brown, style: BorderStyle.solid,
                        )
                      ),
                    child: Theme(
                      data: Theme.of(context).copyWith(canvasColor: globals.selectedWidgetColor),                  
                      child: ButtonTheme(
                          child: FutureBuilder<bool>(
    future: getInterval(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        String? interval;
        if (snapshot.data == true) {
          interval = _intervals[0];
        } else {
          interval = _intervals[1];
        }
        return DropdownButton(
          borderRadius: BorderRadius.circular(30.0),
          items: _intervals.map((String identity) {
            return DropdownMenuItem<String>(
              value: identity,
              child: Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: RichText(
                  text: TextSpan(
                    text: 'Intervalas: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontSize: 20,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: ' $identity '.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          //letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          value: interval,
          onChanged: (value1) {
            //print(value1);
            globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
            if(value1 == 'Mėnesinis'){
              showSnackbar(context, "Sėkmingai nustatyas mėnesinis intervalas", const Duration(seconds: 2));
            } else {
              showSnackbar(context, "Sėkmingai nustatyas savaitinis intervalas", const Duration(seconds: 2));
            }
            setState(() {
              updateInterval(value1.toString());
            });
          },
        );
      } else {
        return const CircularProgressIndicator(); // or any other loading indicator
      }
    },
  ),
  
                      ),
                    ),
                  ),
                  ],
                        ),
              ),
  
            ],)
          ),
  
          
        ],)
    ),
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
          _monthlyIncomeController.text = '$_monthlyIncome';
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
    Future<String> getCurrencySign() async{
    final settingsSnapshot = await FirebaseFirestore.instance.collection(uid).doc('Settings').get();
    if (settingsSnapshot.exists) {
      Map<String, dynamic> data = settingsSnapshot.data()!;
      String bal = data['currency_sign'].toString();
      if(bal.isNotEmpty){
        return bal;
      }
      else{
              FirebaseFirestore.instance.collection(uid).doc('Settings').set({'currency_sign' : '\$'});
      return '\$';
      }

    }
    else
    {
      FirebaseFirestore.instance.collection(uid).doc('Settings').set({'currency_sign' : '\$'});
      return '\$';
    }
  }
  Future updateCurrencySign(String sign) async {
  final curencySetting = FirebaseFirestore.instance.collection(uid).doc('Settings');
  await curencySetting.update({'currency_sign' : sign});
  }
  Future<bool> getInterval() async{
    final settingsSnapshot = await FirebaseFirestore.instance.collection(uid).doc('Settings').get();
    if (settingsSnapshot.exists) {
      Map<String, dynamic> data = settingsSnapshot.data()!;
      String bal = data['monthly'].toString();
      if(bal == 'true' || bal == 'false'){
        //print("pirmas ifas");
        return bal == 'true';
      }
      else{
        //print("pirmas elsas");
        FirebaseFirestore.instance.collection(uid).doc('Settings').set({'monthly' : true});
        return true; 
      }
    }
    else
    {
      FirebaseFirestore.instance.collection(uid).doc('Settings').set({'monthly' : true});
      return true;
    }
  }
  Future updateInterval(String interval) async {
  final curencySetting = FirebaseFirestore.instance.collection(uid).doc('Settings');
  if(interval == 'Mėnesinis'){
    //print("antras ifas");
    await curencySetting.update({'monthly' : true});
  }else{
    //print("antras elsas");
    await curencySetting.update({'monthly' : false});
  }

  }
      
  void updateMoveResidual(bool value) async{
    final settingsSnapshot = await FirebaseFirestore.instance.collection(uid).doc('Settings').get();
    if (settingsSnapshot.exists) {
      Map<String, dynamic> data = settingsSnapshot.data()!;
      String bal = data['moveResidual'].toString();
      if(bal.isNotEmpty){
        FirebaseFirestore.instance.collection(uid).doc('Settings').update({'moveResidual' : value});
      }
      else{
        FirebaseFirestore.instance.collection(uid).doc('Settings').set({'moveResidual' : value});
      }
    }
    else
    {
      FirebaseFirestore.instance.collection(uid).doc('Settings').set({'moveResidual' : value});
    }
  }

  void showSnackbar(BuildContext context, String message, Duration duration) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: duration,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
    