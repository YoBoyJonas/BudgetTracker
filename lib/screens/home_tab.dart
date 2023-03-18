import 'package:budget_tracker/data/expense_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';


class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
      child: Column(children: [
        const SizedBox(
          height: 10,
          ),
        Center(child: Column(children: [
          Text("Balansas", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.5), ), 
          Text("\$" + "2000" , style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          
          ]
        )
        ),
        const SizedBox(
          height: 15,
          width: 30,
          ),
      ],)
      ); 
      
     
    /*const Center(child: Text("Home"),);*/
  }
}