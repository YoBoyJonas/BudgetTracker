import 'package:flutter/material.dart';
import 'package:budget_tracker/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budget_tracker/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProfileTab extends StatefulWidget {
  ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final User? userAuth = Auth().currentUser;
  UserModel userModel = UserModel(nickName: "");
  final TextEditingController _nickNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            displayUserInformation(),
          ]),
    );
  }

  Widget displayUserInformation() {
    return Column(
      children: <Widget>[
        // Email from Firebase auth
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Email: ${userAuth?.email}",
              style: TextStyle(fontSize: 20),
            )),
        // Creation date from Firebase auth
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              // may run into a crash. TODO: find alternative to question mark syntax
              "Created: ${DateFormat('yyyy-MM-dd').format(userAuth?.metadata.creationTime as DateTime)}",
              style: TextStyle(fontSize: 20),
            )),
        // Additional custom user fields
        FutureBuilder(
          future: _getProfileData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              _nickNameController.text = userModel.nickName;
            }

            return Column(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Nickname: ${_nickNameController.text}",
                      style: TextStyle(fontSize: 20),
                    )),
              ],
            );
          },
        ),
        ElevatedButton(
          child: Text("Koreguoti"),
          onPressed: () {
            _userEditBottomSheet(context);
          },
        ),
        _signOutButton(),
      ],
    );
  }

// Function sets userModel values from database
  _getProfileData() async {
    final uid = userAuth?.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((result) {
      userModel.nickName = result['nickName'];
    });
  }

  // Pop-up window for changing user fields
  void _userEditBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, top: 15.0),
                child: Column(
                  children: <Widget>[
                    // Header view with cancel button
                    Row(
                      children: <Widget>[
                        Text("Atnaujinti profilį"),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.cancel),
                          color: Colors.orange,
                          iconSize: 25,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                    // Nickname field
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: TextField(
                              controller: _nickNameController,
                              decoration: InputDecoration(
                                helperText: "Nickname",
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    // Save button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          child: Text('Išsaugoti'),
                          onPressed: () async {
                            userModel.nickName = _nickNameController.text;
                            // setstate updates displayed nickname/profile info after clicking 'Išsaugoti'
                            setState(() {
                              _nickNameController.text = userModel.nickName;
                            });
                            final uid = userAuth?.uid;
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .set(userModel.toJson());

                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    )
                  ],
                ),
              ));
        });
  }

  Future<void> _signOut() async {
    await Auth().signOut();
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: _signOut,
      child: const Text('Atsijungti'),
    );
  }
}
