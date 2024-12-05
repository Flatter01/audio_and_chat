import 'package:firebase_lesson/chat/screen/page/chat_list_screen.dart';
import 'package:firebase_lesson/chat/screen/page/group_screen.dart';
import 'package:firebase_lesson/chat/screen/page/people_screen.dart';
import 'package:firebase_lesson/chat/utilities/assets_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;

  final List<Widget> page = [
    ChatListScreen(),
    GroupScreen(),
    PeopleScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Chat Pro"),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(AssetsManager.userImage),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: page,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2_fill),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.group),
            label: "Group",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.globe),
            label: "People",
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          pageController.animateToPage(index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn);
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
