import 'package:flutter/material.dart';
import 'package:iptv/utils/utils.dart';

class ChannelIPTV extends StatelessWidget {
  final title;
  final image;
  final link;
  final group;
  final onClick;

  const ChannelIPTV(
      {Key key, this.title, this.onClick, this.image, this.link, this.group})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenWidth(context, dividedBy: 4) + 80,
      width: screenWidth(context, dividedBy: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffFF9642).withOpacity(.6)),

        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),

        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: [
        //     Color(0xffFFE05D).withOpacity(.3),
        //     Color(0xffFF9642).withOpacity(.3),
        //   ],
        // ),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          // splashColor: Color(0xffFF9642).withOpacity(.6),
          // hoverColor: Color(0xffFFF8CD).withOpacity(.7),
          borderRadius: BorderRadius.circular(20),
          onTap: onClick,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                image == ''
                    ? Container(
                        height: screenWidth(context, dividedBy: 4),
                        width: screenWidth(context, dividedBy: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            topLeft: Radius.circular(20),
                          ),
                          color: Colors.white54,
                        ),
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.black45,
                            )
                          ],
                        )),
                      )
                    : Container(
                        height: screenWidth(context, dividedBy: 4),
                        width: screenWidth(context, dividedBy: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            topLeft: Radius.circular(20),
                          ),
                          image: DecorationImage(
                            image: NetworkImage('$image'),
                            fit: BoxFit.fill,
                          ),
                          color: Colors.white54,
                        ),
                      ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    '$title',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 8,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    // overflow: TextOverflow.ellipsis,
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
