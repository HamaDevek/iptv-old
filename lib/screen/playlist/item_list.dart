import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iptv/utils/utils.dart';

class PlaylistList extends StatelessWidget {
  final data, delete, edit, show, close, update;

  const PlaylistList(
      {Key key,
      this.data,
      this.delete,
      this.edit,
      this.show,
      this.close,
      this.update})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      color: Colors.black12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: screenWidth(context),
            height: 89,
            color: Colors.white,
            child: InkWell(
              onTap: () {
                show();
                Navigator.of(context)
                    .pushNamed('/group', arguments: data)
                    .whenComplete((){close();enableRotation();});
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CircleAvatar(
                      backgroundColor: Color(0xffFFE05D).withOpacity(0.5),
                      child: Center(
                        child: data['type'] == 1
                            ? IconButton(
                                icon: Icon(
                                  Icons.refresh,
                                  color: Color(0xff646464),
                                ),
                                onPressed: update,
                              )
                            : Icon(
                                Icons.tv_outlined,
                                color: Color(0xff646464),
                              ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            "${data['name']}",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "${data['link']}",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 12, color: Colors.black45),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: FaIcon(
                      FontAwesomeIcons.ellipsisV,
                      color: Colors.black26,
                      size: 16,
                    ),
                    onSelected: (e) {
                      if (e == "EDIT") {
                        edit();
                      }
                      if (e == "DELETE") {
                        delete();
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                      data['type'] == 1
                          ? PopupMenuItem(
                              height: 12,
                              value: "EDIT",
                              child: ListTile(
                                title: Text("Edit"),
                                leading: Icon(
                                  Icons.edit,
                                  size: 20,
                                ),
                              ),
                            )
                          : null,
                      PopupMenuDivider(
                        height: 10,
                      ),
                      PopupMenuItem(
                        height: 12,
                        value: "DELETE",
                        child: ListTile(
                          title: Text("Delete"),
                          leading: Icon(
                            Icons.delete,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
