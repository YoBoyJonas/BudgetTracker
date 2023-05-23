
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:budget_tracker/globals/globals.dart' as globals;
import 'package:isoweek/isoweek.dart';
import 'package:provider/provider.dart';

import '../background_provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  double totalBalance = 0;
  double totalExpenses = 0;
  //current users UID
  final uid = FirebaseAuth.instance.currentUser!.uid;
  //gets todays date
  DateTime todaysDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final backgroundProvider = Provider.of<BackgroundProvider>(context);
    final backgroundImage = backgroundProvider.backgroundImage;
    return MaterialApp(
      home: Stack(
        children: [
          if (backgroundImage != null)  
          Container(
            decoration: BoxDecoration(
            image: DecorationImage(image: backgroundImage!, fit: BoxFit.cover)
            ),
          ),

          Scaffold(
              appBar: AppBar(
                title: FutureBuilder<String>(
                  future: getUserNickName(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else {
                      return Text(
                        'Labas, ${snapshot.data}!',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.blue,
                            decoration: TextDecoration.none,
                          ),
                        );
                    }
                  }
                ),
                flexibleSpace: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green,
                        globals.selectedWidgetColor,
                        globals.selectedWidgetColor,
                        Colors.red,
                      ],
                      stops: const [0.0, 0.2, 0.8, 1.0],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      tileMode: TileMode.clamp,
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.brown,
                        width: MediaQuery.of(context).size.width * 0.007,
                      ),
                    ),
                  ),
                ),
              centerTitle: true,
            ),
            backgroundColor: Colors.transparent,
            body: 
            FutureBuilder<bool>(
              future: getInterval(),
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  if(snapshot.data == true){
                                    return FutureBuilder<List<Map<String, double>>>(
                    future: Future.wait([
                      getMonthData(formatDate(todaysDate.subtract(const Duration(days: 30)), [yyyy, mm])),
                      getMonthData(formatDate(todaysDate, [yyyy, mm])),
                      getMonthlyIncome(),
                    ]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      
                      if (snapshot.hasData) {
                        double previousMonthBalance = snapshot.data![0]['balance']!;
                        double currentMonthBalance = snapshot.data![1]['balance']!;
                        double currentMonthExpense = snapshot.data![1]['expense']!;
                        double monthlyIncome = snapshot.data![2]['income']!;
            
                        if (globals.carryOverSurplusMoney && previousMonthBalance > 0){
                          totalBalance = previousMonthBalance + currentMonthBalance;
                        } else {
                          totalBalance = currentMonthBalance;
                        }
                        totalBalance += monthlyIncome;
                        totalExpenses = currentMonthExpense;
                      }
            
            
                      return ListView(
                        children:[
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.45,
                                  child: Container(                          
                                    decoration: BoxDecoration(
                                      color: globals.selectedWidgetColor,
                                      borderRadius: BorderRadius.circular(70),
                                      border: Border.all(
                                        width: MediaQuery.of(context).size.width * 0.007,
                                        color: Colors.brown, style: BorderStyle.solid,
                                      )
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10.0,
                                      horizontal: 8.0,
                                    ),
                                    child: FutureBuilder<String>(
                                      future: getCurrencySign(),
                                      builder: (context, snapshot) {
                                      if(snapshot.hasData)
                                      {  
                                        String sign = snapshot.data!.toString();
                                        return Column(
                                          children: [
                                            const Text(
                                              'BALANSAS',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 22.0,
                                                color: Colors.green,
                                                letterSpacing: 1.5,   
                                                fontWeight: FontWeight.bold                   
                                              ),
                                            ),
                                            Text(
                                                '$totalBalance $sign',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                fontSize: 26.0,
                                                color: Colors.green,
                                              ),
                                            ),           
                                          ],
                                        );
                                      }
                                      else{
                                        return const CircularProgressIndicator();
                                      }
                                      }
                                    ),
                                  ),
                                ),
                              ),
            
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.44,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: globals.selectedWidgetColor,
                                        borderRadius: BorderRadius.circular(70),
                                        border: Border.all(
                                          width: MediaQuery.of(context).size.width * 0.007,
                                          color: Colors.brown, style: BorderStyle.solid,
                                        )
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10.0,
                                        horizontal: 8.0,
                                      ),
                                      child: FutureBuilder<String>(
                                        future: getCurrencySign(),
                                        builder: (context, snapshot) {
                                          if(snapshot.hasData)
                                          {
                                          String sign = snapshot.data!.toString();
                                          return Column(
                                            children: [
                                              const Text(
                                                'IŠLEISTA',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 22.0,
                                                  color: Colors.redAccent,
                                                  letterSpacing: 1.5,      
                                                  fontWeight: FontWeight.bold                
                                                ),
                                              ),
                                              Text(
                                                  '$totalExpenses $sign',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                  fontSize: 26.0,
                                                  color: Colors.redAccent,
                                                ),
                                              ),           
                                            ],
                                          );
                                          } else {
                                            return const CircularProgressIndicator();
                                          }
                                        }
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ]
                      );
                    }
                  );
                  }
                  //jeigu savaitinis ---------------------
                  else{
                    Week currentWeek = Week.current();
                    Week lastWeek = currentWeek.previous; 
                    Week weekFromIso = Week.fromISOString(currentWeek.toString());
                    Week lastWeekFromIso = Week.fromISOString(lastWeek.toString());
                    return FutureBuilder<List<Map<String, double>>>(
                    future: Future.wait([
                      getMonthData(lastWeekFromIso.toString()),
                      getMonthData(weekFromIso.toString()),
                      getMonthlyIncome(),
                    ]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      
                      if (snapshot.hasData) {
                        double previousMonthBalance = snapshot.data![0]['balance']!;
                        double currentMonthBalance = snapshot.data![1]['balance']!;
                        double currentMonthExpense = snapshot.data![1]['expense']!;
                        double monthlyIncome = snapshot.data![2]['income']!;
            
                        if (globals.carryOverSurplusMoney && previousMonthBalance > 0){
                          totalBalance = previousMonthBalance + currentMonthBalance;
                        } else {
                          totalBalance = currentMonthBalance;
                        }
                        totalBalance += monthlyIncome;
                        totalExpenses = currentMonthExpense;
                      }
            
            
                      return ListView(
                        children:[
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.45,
                                  child: Container(                          
                                    decoration: BoxDecoration(
                                      color: globals.selectedWidgetColor,
                                      borderRadius: BorderRadius.circular(70),
                                      border: Border.all(
                                        width: MediaQuery.of(context).size.width * 0.007,
                                        color: Colors.brown, style: BorderStyle.solid,
                                      )
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10.0,
                                      horizontal: 8.0,
                                    ),
                                    child: FutureBuilder<String>(
                                      future: getCurrencySign(),
                                      builder: (context, snapshot) {
                                      if(snapshot.hasData)
                                      {  
                                        String sign = snapshot.data!.toString();
                                        return Column(
                                          children: [
                                            const Text(
                                              'BALANSAS',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 22.0,
                                                color: Colors.green,
                                                letterSpacing: 1.5,   
                                                fontWeight: FontWeight.bold                   
                                              ),
                                            ),
                                            Text(
                                                '$totalBalance $sign',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                fontSize: 26.0,
                                                color: Colors.green,
                                              ),
                                            ),           
                                          ],
                                        );
                                      }
                                      else{
                                        return const CircularProgressIndicator();
                                      }
                                      }
                                    ),
                                  ),
                                ),
                              ),
            
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.44,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: globals.selectedWidgetColor,
                                        borderRadius: BorderRadius.circular(70),
                                        border: Border.all(
                                          width: MediaQuery.of(context).size.width * 0.007,
                                          color: Colors.brown, style: BorderStyle.solid,
                                        )
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10.0,
                                        horizontal: 8.0,
                                      ),
                                      child: FutureBuilder<String>(
                                        future: getCurrencySign(),
                                        builder: (context, snapshot) {
                                          if(snapshot.hasData)
                                          {
                                          String sign = snapshot.data!.toString();
                                          return Column(
                                            children: [
                                              const Text(
                                                'IŠLEISTA',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 22.0,
                                                  color: Colors.redAccent,
                                                  letterSpacing: 1.5,      
                                                  fontWeight: FontWeight.bold                
                                                ),
                                              ),
                                              Text(
                                                  '$totalExpenses $sign',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                  fontSize: 26.0,
                                                  color: Colors.redAccent,
                                                ),
                                              ),           
                                            ],
                                          );
                                          } else {
                                            return const CircularProgressIndicator();
                                          }
                                        }
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ]
                      );
                    }
                  );
                  }
                }
                else{
                  return const CircularProgressIndicator();
                }

              }
            ),
              
          ),

          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.6), 
            child: 
              Container(
                decoration: BoxDecoration(
                  color: globals.selectedWidgetColor,
                  borderRadius: const BorderRadius.vertical(),
                    border: Border.all(
                      width: MediaQuery.of(context).size.width * 0.007,
                      color: Colors.brown, style: BorderStyle.solid,
                    )
                  ),
                child: FutureBuilder<bool>(
                  future: getInterval(),
                  builder: (context, snapshot) {
                    if(snapshot.hasData){
                      if(snapshot.data == true){
                        return Column(
                      children: [     
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                              child: Container(
                                padding: const EdgeInsets.only(top: 5, right: 10),
                                child: Row(
                                  children: [
                                    RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.zero, 
                                                topRight: Radius.elliptical(20.0, 20.0), 
                                                bottomLeft: Radius.elliptical(20.0, 20.0), 
                                                bottomRight: Radius.circular(10.0)
                                                ),
                                            ),
                                          child: Padding(
                                          padding: const EdgeInsets.only(left: 12, right: 12, top: 5, bottom: 2),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.volume_up,
                                                  size: MediaQuery.of(context).size.width * 0.07,
                                                  color: globals.selectedWidgetColor,
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                                                Text(
                                                  globals.soundEnabled ? 'On' : 'Off',
                                                  style: TextStyle(
                                                    color: globals.selectedWidgetColor,
                                                    decoration: TextDecoration.none,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),

                                          ),
                                          )
                                        ),
                                        
                                      ],    
                                    ),
                                    ),
                                    SizedBox(width: MediaQuery.of(context).size.width * 0.225),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          WidgetSpan(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.elliptical(20.0, 20.0), 
                                                topRight: Radius.zero, 
                                                bottomLeft: Radius.circular(10.0), 
                                                bottomRight: Radius.elliptical(20.0, 20.0)
                                                ),
                                            ),
                            
                                          child: Padding(
                                              padding: const EdgeInsets.only(left: 12, right: 12, top: 5, bottom: 2),
                                              child: RichText (
                                                textAlign: TextAlign.center,
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "PRIMINTUKAS", 
                                                      style: TextStyle(color: globals.selectedWidgetColor, letterSpacing: 2, fontSize: 26, fontWeight: FontWeight.bold, decoration: TextDecoration.none)
                                                    ),
                                                  ]),)
                                          ),
                                          ),    
                                        ), 
                                        ]))
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                
                        Container(padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01)),
                          Row(
                          children: [
                              Padding(
                                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.95,
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.elliptical(20.0, 20.0), 
                                              topRight: Radius.elliptical(20.0, 20.0), 
                                              bottomLeft: Radius.zero, 
                                              bottomRight: Radius.zero),
                                          ),

                                        child: Padding(
                                            padding: const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 2),
                                            child: RichText (
                                              textAlign: TextAlign.center,
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: "Daugiausiai išleista ", 
                                                    style: TextStyle(color: globals.selectedWidgetColor, letterSpacing: 1.8, fontSize: 18, fontWeight: FontWeight.bold)
                                                  ),
                                                ]),)
                                        ),
                                        ),    
                                      ), 
                                    ],    
                                  ),
                                  ),
                                ),
                            ]
                        ),
                
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only( left: MediaQuery.of(context).size.width * 0.02),
                              child: FutureBuilder<String>(
                                future: getMaxName(),
                                builder: (context, snapshot){
                                  if (snapshot.hasData) {
                                    return Row(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.95,
                                          decoration: const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
                                          child: RichText (
                                            textAlign: TextAlign.center,
                                            text: TextSpan(
                                              children: [
                                                WidgetSpan(
                                                  child: 
                                                  Text(
                                                    snapshot.data!,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(color: Colors.redAccent,letterSpacing: 1.5,
                                                      fontSize: 16,
                                                      decoration: TextDecoration.none
                                                    ),
                                                  ),)
                                              ]),)
                                      ),
                                        ),
                                        
                                      ],
                                    );
                
                                  } else if (snapshot.hasError) {
                                    return Row(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.95,
                                          decoration: const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
                                          child: RichText (
                                            textAlign: TextAlign.center,
                                            text: const TextSpan(
                                              children: [
                                                WidgetSpan(
                                                  child: 
                                                  Text(
                                                    "neturite išlaidų",
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(color: Colors.redAccent,letterSpacing: 1.5,
                                                      fontSize: 16,
                                                      decoration: TextDecoration.none
                                                    ),
                                                  ),)
                                              ]),)
                                      ),
                                        ),
                                      ],
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                          ],
                        ),
                          
                        Row(
                          children: [
                            Container(
                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                              child: FutureBuilder<String>(
                                future: getCurrencySign(),
                                builder: (context, snapshot1) {
                                  if(snapshot1.hasData){
                                  String sign = snapshot1.data!.toString();
                                  return FutureBuilder<double>(
                                    future: getMaxExpense(),
                                    builder: (context, snapshot){
                                      if (snapshot.hasData) {
                                        return Row(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.95,
                                                decoration: const BoxDecoration(
                                                color: Colors.black,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
                                                child: RichText (
                                                  textAlign: TextAlign.center,
                                                  text: TextSpan(
                                                    children: [
                                                      WidgetSpan(
                                                        child: 
                                                        Text(
                                                          '${snapshot.data!.toString()} $sign',
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(color: Colors.redAccent,letterSpacing: 1.5,
                                                            fontSize: 16,
                                                            decoration: TextDecoration.none
                                                          ),
                                                        ),)
                                                    ]),)
                                              ),
                                              ),
                                            ],
                                          );
                                      } else if (snapshot.hasError) {
                                          return Row(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.95,
                                                decoration: const BoxDecoration(
                                                color: Colors.black,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
                                                child: RichText (
                                                  textAlign: TextAlign.center,
                                                  text: const TextSpan(
                                                    children: [
                                                      WidgetSpan(
                                                        child: 
                                                        Text(
                                                          "neturite išlaidų",
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(color: Colors.redAccent,letterSpacing: 1.5,
                                                            fontSize: 16,
                                                            decoration: TextDecoration.none
                                                          ),
                                                        ),)
                                                    ]),)
                                              ) ,
                                              ),
                                            ],
                                          );
                                        }
                                      return const SizedBox();
                                    },
                                  );} else {
                                    return FutureBuilder<double>(
                                    future: getMaxExpense(),
                                    builder: (context, snapshot){
                                      if (snapshot.hasData) {
                                        return Row(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.95,
                                                decoration: const BoxDecoration(
                                                color: Colors.black,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
                                                child: RichText (
                                                  textAlign: TextAlign.center,
                                                  text: TextSpan(
                                                    children: [
                                                      WidgetSpan(
                                                        child: 
                                                        Expanded(
                                                          child: Text(
                                                            '${snapshot.data!.toString()} \$',
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: const TextStyle(color: Colors.redAccent,letterSpacing: 1.5,
                                                              fontSize: 16,
                                                              decoration: TextDecoration.none
                                                            ),
                                                          ),
                                                      ),)
                                                    ]),)
                                              ),
                                              ),
                                            ],
                                          );
                                      } else if (snapshot.hasError) {
                                          return Row(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.95,
                                                decoration: const BoxDecoration(
                                                color: Colors.black,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
                                                child: RichText (
                                                  textAlign: TextAlign.center,
                                                  text: const TextSpan(
                                                    children: [
                                                      WidgetSpan(
                                                        child: 
                                                        Expanded(
                                                          child: Text(
                                                            "neturite išlaidų",
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(color: Colors.redAccent,letterSpacing: 1.5,
                                                              fontSize: 16,
                                                              decoration: TextDecoration.none
                                                            ),
                                                          ),
                                                      ),)
                                                    ]),)
                                              ) ,
                                              ),
                                            ],
                                          );
                                        }
                                      return const SizedBox();
                                    },
                                  );
                                  }
                                }
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                              Padding(
                                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.95,
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.zero, 
                                              topRight: Radius.zero, 
                                              bottomLeft: Radius.elliptical(20.0, 20.0), 
                                              bottomRight: Radius.elliptical(20.0, 20.0)),
                                          ),

                                        child: Padding(
                                            padding: const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 2),
                                            child: RichText (
                                              textAlign: TextAlign.center,
                                              text: const TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: " ", 
                                                    style: TextStyle(color: Colors.transparent, letterSpacing: 1.8, fontSize: 18, fontWeight: FontWeight.bold)
                                                  ),
                                                ]),)
                                        ),
                                        ),    
                                      ), 
                                    ],    
                                  ),
                                  ),
                                ),
                            ]
                        ),

                        SizedBox(height: MediaQuery.of(context).size.width * 0.05),
                        Row(
                          children: [
                              Padding(
                                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.95,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(70), 
                                              topRight: Radius.circular(70), 
                                              bottomLeft: Radius.circular(70), 
                                              bottomRight: Radius.circular(70)),
                                            border: Border.all(
                                              width: MediaQuery.of(context).size.width * 0.003,
                                              color: Colors.brown, style: BorderStyle.solid,
                                            )
                                          ),

                                        child: Padding(
                                            padding: const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 2),
                                            child: RichText (
                                              textAlign: TextAlign.center,
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: "FONAS - ", 
                                                    style: TextStyle(color: globals.selectedWidgetColor, letterSpacing: 1.8, fontSize: 18, fontWeight: FontWeight.bold)
                                                  ),

                                                  TextSpan(
                                                    text: globals.selected, 
                                                    style: TextStyle(
                                                      color: globals.selectedWidgetColor,
                                                      letterSpacing: 1.8,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      decoration: TextDecoration.none,
                                                      ),
                                                  ),
                                                  

                                                  TextSpan(
                                                    text: " plytos", 
                                                    style: TextStyle(color: globals.selectedWidgetColor, letterSpacing: 1.8, fontSize: 18, fontWeight: FontWeight.bold)        
                                                  ),

                                                ]),)
                                        ),
                                        ),    
                                      ), 
                                    ],    
                                  ),
                                  ),
                                ),
                            ]
                        ),
                            ],                                                  
                        );
                      }








                      else{
                        return Column(
                      children: [     
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                              child: Container(
                                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05, right: MediaQuery.of(context).size.height * 0.1),
                                child: Row(
                                  children: [
                                    RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.zero, 
                                                topRight: Radius.elliptical(20.0, 20.0), 
                                                bottomLeft: Radius.elliptical(20.0, 20.0), 
                                                bottomRight: Radius.circular(10.0)
                                                ),
                                            ),
                                          child: Padding(
                                          padding: EdgeInsets.only(
                                            left: MediaQuery.of(context).size.height * 0.12,
                                            right: MediaQuery.of(context).size.height * 0.12,
                                             top: MediaQuery.of(context).size.height * 0.05,
                                              bottom: MediaQuery.of(context).size.height * 0.02),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.volume_up,
                                                  size: MediaQuery.of(context).size.width * 0.07,
                                                  color: globals.selectedWidgetColor,
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                                                Text(
                                                  globals.soundEnabled ? 'On' : 'Off',
                                                  style: TextStyle(
                                                    color: globals.selectedWidgetColor,
                                                    decoration: TextDecoration.none,
                                                    fontSize: MediaQuery.of(context).size.height * 0.15,
                                                  ),
                                                ),
                                              ],
                                            ),

                                          ),
                                          )
                                        ),
                                        
                                      ],    
                                    ),
                                    ),
                                    SizedBox(width: MediaQuery.of(context).size.width * 0.2),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          WidgetSpan(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.elliptical(20.0, 20.0), 
                                                topRight: Radius.zero, 
                                                bottomLeft: Radius.circular(10.0), 
                                                bottomRight: Radius.elliptical(20.0, 20.0)
                                                ),
                                            ),
                            
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                            left: MediaQuery.of(context).size.height * 0.12,
                                            right: MediaQuery.of(context).size.height * 0.12,
                                             top: MediaQuery.of(context).size.height * 0.05,
                                              bottom: MediaQuery.of(context).size.height * 0.02),
                                              child: RichText (
                                                textAlign: TextAlign.center,
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "PRIMINTUKAS", 
                                                      style: TextStyle(color: globals.selectedWidgetColor, letterSpacing: MediaQuery.of(context).size.width * 0.02, fontSize: MediaQuery.of(context).size.width * 0.26, fontWeight: FontWeight.bold, decoration: TextDecoration.none)
                                                    ),
                                                  ]),)
                                          ),
                                          ),    
                                        ), 
                                        ]))
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                
                        Container(padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01)),
                          Row(
                          children: [
                              Padding(
                                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.95,
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.elliptical(20.0, 20.0), 
                                              topRight: Radius.elliptical(20.0, 20.0), 
                                              bottomLeft: Radius.zero, 
                                              bottomRight: Radius.zero),
                                          ),

                                        child: Padding(
                                            padding: EdgeInsets.only(
                                              left: MediaQuery.of(context).size.height * 0.12,
                                            right: MediaQuery.of(context).size.height * 0.12,
                                             top: MediaQuery.of(context).size.height * 0.05,
                                              bottom: MediaQuery.of(context).size.height * 0.02),
                                            child: RichText (
                                              textAlign: TextAlign.center,
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: "Daugiausiai išleista ", 
                                                    style: TextStyle(color: globals.selectedWidgetColor, letterSpacing: 1.8, fontSize: MediaQuery.of(context).size.height * 0.18, fontWeight: FontWeight.bold)
                                                  ),
                                                ]),)
                                        ),
                                        ),    
                                      ), 
                                    ],    
                                  ),
                                  ),
                                ),
                            ]
                        ),
                
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only( left: MediaQuery.of(context).size.width * 0.02),
                              child: FutureBuilder<String>(
                                future: getMaxWeeklyName(),
                                builder: (context, snapshot){
                                  if (snapshot.hasData) {
                                    return Row(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.95,
                                          decoration: const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: MediaQuery.of(context).size.height * 0.05,
                                            right: MediaQuery.of(context).size.height * 0.05,
                                             top: MediaQuery.of(context).size.height * 0.03,
                                              bottom: MediaQuery.of(context).size.height * 0.03),
                                          child: RichText (
                                            textAlign: TextAlign.center,
                                            text: TextSpan(
                                              children: [
                                                WidgetSpan(
                                                  child: 
                                                  Text(
                                                    snapshot.data!,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(color: Colors.redAccent,letterSpacing: 1.5,
                                                      fontSize: 16,
                                                      decoration: TextDecoration.none
                                                    ),
                                                  ),)
                                              ]),)
                                      ),
                                        ),
                                        
                                      ],
                                    );
                
                                  } else if (snapshot.hasError) {
                                    return Row(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.95,
                                          decoration: const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: MediaQuery.of(context).size.height * 0.05,
                                            right: MediaQuery.of(context).size.height * 0.05,
                                             top: MediaQuery.of(context).size.height * 0.03,
                                              bottom: MediaQuery.of(context).size.height * 0.03),
                                          child: RichText (
                                            textAlign: TextAlign.center,
                                            text: const TextSpan(
                                              children: [
                                                WidgetSpan(
                                                  child: 
                                                  Text(
                                                    "neturite išlaidų",
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(color: Colors.redAccent,letterSpacing: 1.5,
                                                      fontSize: 16,
                                                      decoration: TextDecoration.none
                                                    ),
                                                  ),)
                                              ]),)
                                      ),
                                        ),
                                      ],
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                          ],
                        ),
                          
                        Row(
                          children: [
                            Container(
                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                              child: FutureBuilder<String>(
                                future: getCurrencySign(),
                                builder: (context, snapshot1) {
                                  if(snapshot1.hasData){
                                  String sign = snapshot1.data!.toString();
                                  return FutureBuilder<double>(
                                    future: getMaxWeeklyExpense(),
                                    builder: (context, snapshot){
                                      if (snapshot.hasData) {
                                        return Row(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.95,
                                                decoration: const BoxDecoration(
                                                color: Colors.black,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                              left: MediaQuery.of(context).size.height * 0.05,
                                            right: MediaQuery.of(context).size.height * 0.05,
                                             top: MediaQuery.of(context).size.height * 0.03,
                                              bottom: MediaQuery.of(context).size.height * 0.03),
                                                child: RichText (
                                                  textAlign: TextAlign.center,
                                                  text: TextSpan(
                                                    children: [
                                                      WidgetSpan(
                                                        child: 
                                                        Text(
                                                          '${snapshot.data!.toString()} $sign',
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(color: Colors.redAccent,letterSpacing: 1.5,
                                                            fontSize: 16,
                                                            decoration: TextDecoration.none
                                                          ),
                                                        ),)
                                                    ]),)
                                              ),
                                              ),
                                            ],
                                          );
                                      } else if (snapshot.hasError) {
                                          return Row(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.95,
                                                decoration: const BoxDecoration(
                                                color: Colors.black,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                              left: MediaQuery.of(context).size.height * 0.05,
                                            right: MediaQuery.of(context).size.height * 0.05,
                                             top: MediaQuery.of(context).size.height * 0.03,
                                              bottom: MediaQuery.of(context).size.height * 0.03),
                                                child: RichText (
                                                  textAlign: TextAlign.center,
                                                  text: const TextSpan(
                                                    children: [
                                                      WidgetSpan(
                                                        child: 
                                                        Text(
                                                          "neturite išlaidų",
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(color: Colors.redAccent,letterSpacing: 1.5,
                                                            fontSize: 16,
                                                            decoration: TextDecoration.none
                                                          ),
                                                        ),)
                                                    ]),)
                                              ) ,
                                              ),
                                            ],
                                          );
                                        }
                                      return const SizedBox();
                                    },
                                  );} else {
                                    return FutureBuilder<double>(
                                    future: getMaxWeeklyExpense(),
                                    builder: (context, snapshot){
                                      if (snapshot.hasData) {
                                        return Row(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.95,
                                                decoration: const BoxDecoration(
                                                color: Colors.black,
                                              ),
                                              child: Padding(
                                                padding:  EdgeInsets.only(
                                              left: MediaQuery.of(context).size.height * 0.05,
                                            right: MediaQuery.of(context).size.height * 0.05,
                                             top: MediaQuery.of(context).size.height * 0.03,
                                              bottom: MediaQuery.of(context).size.height * 0.03),
                                                child: RichText (
                                                  textAlign: TextAlign.center,
                                                  text: TextSpan(
                                                    children: [
                                                      WidgetSpan(
                                                        child: 
                                                        Text(
                                                          '${snapshot.data!.toString()} \$',
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(color: Colors.redAccent,letterSpacing: 1.5,
                                                            fontSize: 16,
                                                            decoration: TextDecoration.none
                                                          ),
                                                        ),)
                                                    ]),)
                                              ),
                                              ),
                                            ],
                                          );
                                      } else if (snapshot.hasError) {
                                          return Row(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.95,
                                                decoration: const BoxDecoration(
                                                color: Colors.black,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                              left: MediaQuery.of(context).size.height * 0.05,
                                            right: MediaQuery.of(context).size.height * 0.05,
                                             top: MediaQuery.of(context).size.height * 0.03,
                                              bottom: MediaQuery.of(context).size.height * 0.03),
                                                child: RichText (
                                                  textAlign: TextAlign.center,
                                                  text: const TextSpan(
                                                    children: [
                                                      WidgetSpan(
                                                        child: 
                                                        Text(
                                                          "neturite išlaidų",
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(color: Colors.redAccent,letterSpacing: 1.5,
                                                            fontSize: 16,
                                                            decoration: TextDecoration.none
                                                          ),
                                                        ),)
                                                    ]),)
                                              ) ,
                                              ),
                                            ],
                                          );
                                        }
                                      return const SizedBox();
                                    },
                                  );
                                  }
                                }
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                              Padding(
                                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.95,
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.zero, 
                                              topRight: Radius.zero, 
                                              bottomLeft: Radius.elliptical(20.0, 20.0), 
                                              bottomRight: Radius.elliptical(20.0, 20.0)),
                                          ),

                                        child: Padding(
                                            padding:  EdgeInsets.only(
                                              left: MediaQuery.of(context).size.height * 0.12,
                                            right: MediaQuery.of(context).size.height * 0.12,
                                             top: MediaQuery.of(context).size.height * 0.02,
                                              bottom: MediaQuery.of(context).size.height * 0.02),
                                            child: RichText (
                                              textAlign: TextAlign.center,
                                              text: const TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: " ", 
                                                    style: TextStyle(color: Colors.transparent, letterSpacing: 1.8, fontSize: 18, fontWeight: FontWeight.bold)
                                                  ),
                                                ]),)
                                        ),
                                        ),    
                                      ), 
                                    ],    
                                  ),
                                  ),
                                ),
                            ]
                        ),

                        SizedBox(height: MediaQuery.of(context).size.width * 0.05),
                        Row(
                          children: [
                              Padding(
                                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.95,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(70), 
                                              topRight: Radius.circular(70), 
                                              bottomLeft: Radius.circular(70), 
                                              bottomRight: Radius.circular(70)),
                                            border: Border.all(
                                              width: MediaQuery.of(context).size.width * 0.003,
                                              color: Colors.brown, style: BorderStyle.solid,
                                            )
                                          ),

                                        child: Padding(
                                            padding: const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 2),
                                            child: RichText (
                                              textAlign: TextAlign.center,
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: "FONAS - ", 
                                                    style: TextStyle(color: globals.selectedWidgetColor, letterSpacing: 1.8, fontSize: 18, fontWeight: FontWeight.bold)
                                                  ),

                                                  TextSpan(
                                                    text: globals.selected, 
                                                    style: TextStyle(
                                                      color: globals.selectedWidgetColor,
                                                      letterSpacing: 1.8,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      decoration: TextDecoration.none,
                                                      ),
                                                  ),
                                                  

                                                  TextSpan(
                                                    text: " plytos", 
                                                    style: TextStyle(color: globals.selectedWidgetColor, letterSpacing: 1.8, fontSize: 18, fontWeight: FontWeight.bold)        
                                                  ),

                                                ]),)
                                        ),
                                        ),    
                                      ), 
                                    ],    
                                  ),
                                  ),
                                ),
                            ]
                        ),
                            ],                                                  
                        );
                      }
                    } else {
                      return const CircularProgressIndicator();
                    }
                    
                  }
                )
                ),
              
              )
        ],
      )
    );
  }

  Future<String> getUserNickName() async {
    DocumentSnapshot result = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

    return result['nickName'] ?? 'User';
  }

  Future<Map<String, double>> getMonthData(String month) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(uid)
        .doc('income_expense')
        .collection('${month}income_expense')
        .get();

    double tempBalance = 0;
    double tempExpense = 0;

    for (var doc in querySnapshot.docs) {
      if (doc["type"] == 'Income') {
        tempBalance += double.parse(doc["amount"]);
      } else if (doc["type"] == 'Expense') {
        tempBalance -= double.parse(doc["amount"]);
        tempExpense += double.parse(doc["amount"]);
      }
    }

    return {'balance': tempBalance, 'expense': tempExpense};
}

  Future<Map<String, double>> getMonthlyIncome() async {
    final element = await FirebaseFirestore.instance
        .collection(uid)
        .doc('monthly_income')
        .get();

    double monthlyIncome = 0;
    if (element.exists) {
      monthlyIncome = (element.data()?['income'] ?? 0).toDouble();
    }

    return {'income': monthlyIncome};
    // return element;
  }

  Future<double> getMaxWeeklyExpense() async{
    Week currentWeek = Week.current(); 
  Week weekFromIso = Week.fromISOString(currentWeek.toString());
    final element = await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('${weekFromIso}MaxExpense').get();
    double maxBalance = element.data()!['Amount'];
    return maxBalance;
  }
    Future<String> getMaxWeeklyName() async{
     Week currentWeek = Week.current(); 
  Week weekFromIso = Week.fromISOString(currentWeek.toString());
    final element = await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('${weekFromIso}MaxExpense').get();
    String maxName = element.data()!['Name'];
    return maxName;
  }

  Future<double> getMaxExpense() async{
    final element = await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('202305MaxExpense').get();
    double maxBalance = element.data()!['Amount'];
    return maxBalance;
  }

  Future<String> getMaxName() async{
    final element = await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('202305MaxExpense').get();
    String maxName = element.data()!['Name'];
    return maxName;
  }
    Future<String> getCurrencySign() async{
    final settingsSnapshot = await FirebaseFirestore.instance.collection(uid).doc('Settings').get();
    if (settingsSnapshot.exists) {
      Map<String, dynamic> data = settingsSnapshot.data()!;
      String bal = data['currency_sign'].toString();
      return bal;
    }
    else
    {
      FirebaseFirestore.instance.collection(uid).doc('Settings').set({'currency_sign' : '\$'});
      return '\$';
    }
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
}
