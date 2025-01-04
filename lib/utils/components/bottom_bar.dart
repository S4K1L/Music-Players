import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:music_player/utils/widgets/mood_selection_page.dart';
import 'package:music_player/view/home_page.dart';
import 'package:music_player/view/music_player.dart';
import 'package:music_player/view/book_mark.dart';
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
    MoodSelectionPage(),
    BookMarkedPage(),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => MusicPlayerPage()));
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.play_arrow_rounded,size: 40,),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          elevation: 10.sp,
          color: kBackGroundColor,
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.sp),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBottomNavigationItem(CupertinoIcons.home, 0, 'Home'),
                      _buildBottomNavigationItem(
                          Icons.recommend, 1, 'Recommended'),
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
            size: 25.sp,
            color: indexColor == index ? kBottomBar : kWhiteColor,
          ),
          if (indexColor == index)
            Padding(
              padding: EdgeInsets.only(top: 5.sp),
              child: Text(
                title,
                style: TextStyle(
                    color: kBottomBar, fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}