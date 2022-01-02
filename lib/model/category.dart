import 'package:flutter/material.dart';
import 'package:iptv/utils/utils.dart';

class Category extends StatelessWidget {
  final category;
  final onClick;

  const Category({Key key, this.category, this.onClick}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenWidth(context, dividedBy: 2.5),
      width: screenWidth(context, dividedBy: 2.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xffFFE05D).withOpacity(.3),
            Color(0xffFF9642).withOpacity(.3),
          ],
        ),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: Color(0xffFFF8CD).withOpacity(.7),
        child: InkWell(
          splashColor: Color(0xffFF9642).withOpacity(.6),
          hoverColor: Color(0xffFFF8CD).withOpacity(.7),
          borderRadius: BorderRadius.circular(20),
          onTap: onClick,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(100),
                      ),
                      color: Colors.white54),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          category == "" ? "O" : "${category[0]}",
                          style: TextStyle(fontSize: 30, color: Colors.black38),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '${category == "" ? "Other" : category}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
