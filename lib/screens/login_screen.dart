import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budget_tracker/auth.dart';

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
                  value: password_strength,
                  backgroundColor: Colors.grey[300],
                  minHeight: 5,
                  color: password_strength <= 1 / 4
                      ? Colors.red
                      : password_strength == 2 / 4
                      ? Colors.yellow
                      : password_strength == 3 / 4
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

  RegExp pass_valid = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");
  double password_strength = 0;
  
  // 0: No password
  // 1/4: Weak
  // 2/4: Medium
  // 3/4: Strong
  //   1:   Great
  //A function that validate user entered password
  bool validatePassword(String pass){
    String _password = pass.trim();
    if(_password.isEmpty){
      setState(() {
        password_strength = 0;
      });
    }else if(_password.length < 6 ){
      setState(() {
        password_strength = 1 / 4;
      });
    }else if(_password.length < 8){
      setState(() {
        password_strength = 2 / 4;
      });
    }else{
      if(pass_valid.hasMatch(_password)){
        setState(() {
          password_strength = 4 / 4;
        });
        return true;
      }else{
        setState(() {
          password_strength = 3 / 4;
        });
        return false;
      }
    }
    return false;
  }
}
