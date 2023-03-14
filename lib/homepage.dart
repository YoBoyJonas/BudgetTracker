
import 'package:flutter/material.dart';

const List<String> list = <String> ['-','Alga', 'Santaupos', 'Dovana'];

class HomePage extends StatefulWidget {
  const HomePage ({Key? key}) : super(key: key);
  

  @override
  _HomePageState createState() =>_HomePageState();
  }

class _HomePageState extends State<HomePage> {
int _selectedIndex = 0;
PageController pageController = PageController();

void onTapped(int index){
  setState(() {
    _selectedIndex = index;
  });  
      pageController.animateToPage(index, duration: Duration(milliseconds: 1000), curve: Curves.fastOutSlowIn);
}

  @override
  Widget build (BuildContext context){  
  
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Biudžeto seklys xd'),
        backgroundColor: Colors.black,
        centerTitle: true,
        titleTextStyle: const TextStyle(color: Colors.amber, fontSize: 20, letterSpacing: 3, fontWeight: FontWeight.w900),
      ),

      body: PageView(
        controller: pageController,
          children: [
            Container( 
              alignment: Alignment.topRight,
              padding: const EdgeInsets.all(8),
              color: Colors.blueGrey,
                child: Column(
                  children: [          
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(       
                        width: 130,
                        height: 50,
                        //suma mygtukas viršaus dešinėje
                        child: SalaryTypingButton(),
                            
                      ),
                    ),

            Container(    
              alignment: Alignment.centerRight,             
              width: 135,
              height: 50,
              // dropdown listas žemiau sumos mygtuko
                child: const DropdownButtonSalary(),              
            ),
          ],       
       ), 
             
      ),
            Container(color: Colors.green),
            Container(color: Colors.blue),
          ], 
      ), 
      


      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>
        [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Pagrindinis'),
        BottomNavigationBarItem(icon: Icon(Icons.query_stats), label: 'Statistika'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Nustatymai'),  

        ], 
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.black,
        onTap: onTapped,

      ),
    );
  }
}

class SalaryTypingButton extends StatefulWidget {
  const SalaryTypingButton({super.key});

  @override
  State<SalaryTypingButton> createState() => _SalaryTypingbuttonState();
}

class _SalaryTypingbuttonState extends State<SalaryTypingButton> {

  @override
  Widget build(BuildContext context){
    return const MaterialApp(
      home: TextField(
        style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 25),                      
        decoration: InputDecoration(
          hintText: 'suma',  
          hintStyle: TextStyle(color: Colors.yellow),                    
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellowAccent)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepOrange)),                     
        ),
      ),

    );
  }
}

class DropdownButtonSalary extends StatefulWidget {
  const DropdownButtonSalary({super.key});

  @override
  State<DropdownButtonSalary> createState() => _DropdownButtonSalaryState();
}

class _DropdownButtonSalaryState extends State<DropdownButtonSalary> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context){
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward, color: Colors.deepOrange),
      style: const TextStyle(color: Colors.deepOrange, fontSize: 20, fontWeight: FontWeight.bold),
      underline: Container(
        height: 4,
        color: Colors.yellowAccent,
      ),
      onChanged: (String? value){
        //this is called when user selects an item
        setState((){
          dropdownValue = value!;
        });
      },

      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
     }).toList(),
    );
  }
}
