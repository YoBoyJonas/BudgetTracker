import 'package:flutter/material.dart';
import 'package:budget_tracker/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budget_tracker/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:budget_tracker/storage_service.dart';
import 'package:budget_tracker/globals/globals.dart' as globals;
import 'package:provider/provider.dart';

import '../background_provider.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final User? userAuth = Auth().currentUser;
  UserModel userModel = UserModel(nickName: "", imageUrl: "");
  final TextEditingController _nickNameController = TextEditingController();
  final Storage storage = Storage();

  @override
  Widget build(BuildContext context) {
    final backgroundProvider = Provider.of<BackgroundProvider>(context);
    final backgroundImage = backgroundProvider.backgroundImage;
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            if (backgroundImage != null)  
            Container(
              decoration: BoxDecoration(
              image: DecorationImage(image: backgroundImage!, fit: BoxFit.cover)
              ),
            ),
      
            Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    displayUserInformation(),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final uid = userAuth?.uid;
      final fileExtension = pickedFile.path.split('.').last;
      final fileName = "$uid.$fileExtension";
      String imageUrl = await storage.uploadFile(pickedFile.path, fileName);
      setState(() {
        userModel.imageUrl = imageUrl;
      });

      // Update imageUrl in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userModel.toJson());
    }
  }

  Widget showProfileImage() {
    return GestureDetector(
      onTap: () {
        _pickImage();
      },
      child: CircleAvatar(
        radius: 100,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 95,
          backgroundImage: userModel.imageUrl != ""
              ? NetworkImage(userModel.imageUrl)
              : const AssetImage('assets/images/default_profile.png')
                  as ImageProvider<Object>,
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  Widget displayUserInformation() {
    return FutureBuilder(
        future: _getProfileData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            _nickNameController.text = userModel.nickName;

            return Column(
              children: <Widget>[
                showProfileImage(),
                // Email from Firebase auth
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(7.0),
                      decoration: BoxDecoration(
                        color: globals.selectedWidgetColor,
                        borderRadius: BorderRadius.circular(70),
                                border: Border.all(
                                  width: MediaQuery.of(context).size.width * 0.007,
                                  color: Colors.brown, style: BorderStyle.solid,
                                )
                      ),
                      child: Text(
                        "Email: ${userAuth?.email}",
                        style: const TextStyle(fontSize: 18, decoration: TextDecoration.none),
                      ),
                    )),
                // Creation date from Firebase auth
                Padding(
                    padding: const EdgeInsets.all(8.0),             
                    child: Container(
                      padding: const EdgeInsets.all(7.0),
                      decoration: BoxDecoration(
                        color: globals.selectedWidgetColor,
                        borderRadius: BorderRadius.circular(70),
                                border: Border.all(
                                  width: MediaQuery.of(context).size.width * 0.007,
                                  color: Colors.brown, style: BorderStyle.solid,
                                )
                      ),
                      child: Text(
                        // may run into a crash.
                        "Created: ${DateFormat('yyyy-MM-dd').format(userAuth?.metadata.creationTime as DateTime)}",
                        style: const TextStyle(fontSize: 18, decoration: TextDecoration.none),
                      ),
                    )),
                // Additional custom user fields
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(7.0),
                      decoration: BoxDecoration(
                        color: globals.selectedWidgetColor,
                        borderRadius: BorderRadius.circular(70),
                                border: Border.all(
                                  width: MediaQuery.of(context).size.width * 0.007,
                                  color: Colors.brown, style: BorderStyle.solid,
                                )
                      ),
                      child: Text(
                        "Nickname: ${_nickNameController.text}",
                        style: const TextStyle(fontSize: 18, decoration: TextDecoration.none),
                      ),
                    )),
                ElevatedButton(
                  child: const Text("Koreguoti"),
                  onPressed: () {
                    globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                    _userEditBottomSheet(context);
                  },
                ),
                _signOutButton(),
              ],
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
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
      userModel.imageUrl = result['imageUrl'];
    });
  }

  // Pop-up window for changing user fields
  void _userEditBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, top: 15.0),
                child: Column(
                  children: <Widget>[
                    // Header view with cancel button
                    Row(
                      children: <Widget>[
                        const Text("Atnaujinti profilį"),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.cancel),
                          color: Colors.orange,
                          iconSize: 25,
                          onPressed: () {
                            globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
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
                              decoration: const InputDecoration(
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
                          child: const Text('Išsaugoti'),
                          onPressed: () async {
                            globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                            userModel.nickName = _nickNameController.text;
                            // setstate updates displayed nickname/profile info after clicking 'Išsaugoti'
                            setState(() {
                              _nickNameController.text = userModel.nickName;
                            });
                            final uid = userAuth?.uid;
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .set(userModel.toJson())
                                .then((_) {
                                  // Show a snackbar
                                  final snackBar = SnackBar(
                                    content: Text("Sėkmingai pakeistas pavadinimas, ${userModel.nickName}"),
                                    duration: const Duration(seconds: 2),
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                });

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
