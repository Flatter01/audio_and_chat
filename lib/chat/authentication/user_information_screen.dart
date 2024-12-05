import 'package:firebase_lesson/chat/screen/chat_screen.dart';
import 'package:firebase_lesson/chat/utilities/assets_manager.dart';
import 'package:flutter/material.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("User Information"),
      ),
      body: Center(
        child: Column(
          children: [
           const Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(AssetsManager.userImage),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                    (route) => false,
                  );
                },
                child: Text("Home Screen"))
          ],
        ),
      ),
    );
  }
}
