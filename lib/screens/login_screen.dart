import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budget_tracker/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
          final uid = FirebaseAuth.instance.currentUser!.uid;
          final curencySetting = FirebaseFirestore.instance.collection(uid).doc('Settings').set({'currency_sign' : '\$'});
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }


  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : '$errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed:
          isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      child: Text(isLogin ? 'Login' : 'Register'),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(isLogin ? 'Register instead' : 'Login instead'),
    );
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Seklys'),
      ),

      body: Center(

        child: Form(
          key: _formKey,

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            //email text field
            Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  //controller: _controllerEmail,
                  validator: (value){
                      if(value!.isEmpty){
                        return "Please enter your E-mail";
                      }
                      else {
                        // sets textbox value to controller
                        _controllerEmail.text = value;
                        return null;
                      }
                  },
                  decoration: const InputDecoration(border: OutlineInputBorder(),hintText: "E-mail"),
                ),
              ),
              //password text field
              Padding(
              
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  onChanged: (value){
                    _formKey.currentState!.validate();
                  },
                  validator: (value){
                      if(value!.isEmpty){
                        return "Please enter password";
                      }else{
                       //call function to check password
                        bool result = validatePassword(value);
                        if(result){
                          // sets textbox value to controller
                          _controllerPassword.text = value;
                         return null;
                        }else{
                          return " Password should contain Capital, small letter & Number & Special";
                        }
                      }
                  },
                  decoration: const InputDecoration(border: OutlineInputBorder(),hintText: "Password"),
                ),
              ),
              // password strength bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                //only shows when registering (isLogin == false)
                child: !isLogin ? LinearProgressIndicator(
                  value: passwordStrength,
                  backgroundColor: Colors.grey[300],
                  minHeight: 5,
                  color: passwordStrength <= 1 / 4
                      ? Colors.red
                      : passwordStrength == 2 / 4
                      ? Colors.yellow
                      : passwordStrength == 3 / 4
                      ? Colors.blue
                      : Colors.green,
                ) : null,
              ),
              
              _submitButton(),
              _errorMessage(),
              _loginOrRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  RegExp passValid = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");
  double passwordStrength = 0;
  
  // 0: No password
  // 1/4: Weak
  // 2/4: Medium
  // 3/4: Strong
  //   1:   Great
  //A function that validate user entered password
  bool validatePassword(String pass){
    String password = pass.trim();
    if(password.isEmpty){
      setState(() {
        passwordStrength = 0;
      });
    }else if(password.length < 6 ){
      setState(() {
        passwordStrength = 1 / 4;
      });
    }else if(password.length < 8){
      setState(() {
        passwordStrength = 2 / 4;
      });
    }else{
      if(passValid.hasMatch(password)){
        setState(() {
          passwordStrength = 4 / 4;
        });
        return true;
      }else{
        setState(() {
          passwordStrength = 3 / 4;
        });
        return false;
      }
    }
    return false;
  }
}
