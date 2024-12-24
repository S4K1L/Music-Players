import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_player/view/home_page.dart';
import 'package:music_player/view/music_player.dart';
import 'package:music_player/view/play_list.dart';
import 'package:music_player/view/profile_page.dart';
import '../constant/colors.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int indexColor = 0;
  List<Widget> screens = [
    HomePage(),
    MusicPlayerPage(),
    RecommendedPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: screens[indexColor],
        bottomNavigationBar: BottomAppBar(
          elevation: 10,
          color: kBackGroundColor,
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBottomNavigationItem(CupertinoIcons.home, 0, 'Home'),
                      _buildBottomNavigationItem(
                          Icons.play_circle_outline, 1, 'Music'),
                      _buildBottomNavigationItem(Icons.bookmark_add_outlined, 2, 'Bookmark'),
                      _buildBottomNavigationItem(Icons.spoke_outlined, 3, 'Account'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationItem(IconData icon, int index, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          indexColor = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 25,
            color: indexColor == index ? kBottomBar : kWhiteColor,
          ),
          if (indexColor == index)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                title,
                style: const TextStyle(
                    color: kBottomBar, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}