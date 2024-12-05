import 'package:firebase_lesson/chat/screen/chat_screen.dart';
import 'package:firebase_lesson/chat/utilities/assets_manager.dart';
import 'package:flutter/material.dart';
// import 'package:rounded_loading_button/rounded_loading_button.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  // final RoundedLoadingButtonController _btuController =
  //     RoundedLoadingButtonController();
      final TextEditingController _nameController = TextEditingController();

      @override
  void dispose() {
    // _btuController.stop();
    _nameController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("User Information"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Column(
            children: [
              const Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(AssetsManager.userImage),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration:const InputDecoration(
                  hintText: "Enter your name",
                  border: OutlineInputBorder(),
                ),
              )
              // ElevatedButton(
              //     onPressed: () {
              //       Navigator.pushAndRemoveUntil(
              //         context,
              //         MaterialPageRoute(builder: (context) => const ChatScreen()),
              //         (route) => false,
              //       );
              //     },
              //     child: Text("Home Screen"))
            ],
          ),
        ),
      ),
    );
  }
}
