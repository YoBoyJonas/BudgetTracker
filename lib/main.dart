import 'package:flutter/material.dart';
import 'package:budget_tracker/screens/main_screen.dart';
import 'package:budget_tracker/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:provider/provider.dart';
import 'package:budget_tracker/data/expense_data.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // return ChangeNotifierProvider(create: (context) => ExpenseData(),
    // builder: (context, child) => const MaterialApp(
    //   home: WidgetTree(),
    // ),
    // );
    return const MaterialApp(
       home: WidgetTree(),
    );
  }
}
