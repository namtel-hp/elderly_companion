import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderlycompanion/models/user.dart';
import 'package:elderlycompanion/screens/documents/view_documents.dart';
import 'package:elderlycompanion/screens/elders/link_elder.dart';
import 'package:elderlycompanion/screens/video_call/video_call.dart';
import 'package:elderlycompanion/widgets/app_default.dart';
import 'package:elderlycompanion/widgets/home_screen_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart'
    as PermissionManager;
import 'package:sweet_alert_dialogs/sweet_alert_dialogs.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  checkRequiredPermission() async {
    bool permissionEnabled, serviceEnabled;
    permissionEnabled = false;
    serviceEnabled = false;
    PermissionManager.PermissionStatus cameraPermission, microPhonePermission;

    if (!(permissionEnabled && serviceEnabled)) {
      cameraPermission = await PermissionManager.PermissionHandler()
          .checkPermissionStatus(PermissionManager.PermissionGroup.camera);
      cameraPermission = await PermissionManager.PermissionHandler()
          .checkPermissionStatus(PermissionManager.PermissionGroup.microphone);
      if (cameraPermission == PermissionManager.PermissionStatus.granted &&
          microPhonePermission == PermissionManager.PermissionStatus.granted) {
        setState(() {
          permissionEnabled = true;
        });

        PermissionManager.ServiceStatus cameraServiceStatus =
            await PermissionManager.PermissionHandler()
                .checkServiceStatus(PermissionManager.PermissionGroup.camera);

        PermissionManager.ServiceStatus microPhoneServiceStatus =
            await PermissionManager.PermissionHandler().checkServiceStatus(
                PermissionManager.PermissionGroup.microphone);
        if (cameraServiceStatus == PermissionManager.ServiceStatus.enabled &&
            microPhoneServiceStatus ==
                PermissionManager.ServiceStatus.enabled) {
          setState(() {
            serviceEnabled = true;
          });
        }
      } else {
        await PermissionManager.PermissionHandler().requestPermissions([
          PermissionManager.PermissionGroup.camera,
          PermissionManager.PermissionGroup.microphone
        ]);
        setState(() {
          serviceEnabled = true;
          permissionEnabled = true;
        });
      }
    }
    return serviceEnabled && permissionEnabled;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return RichAlertDialog(
                alertTitle: richTitle("Exit the App"),
                alertSubtitle: richSubtitle('Are you Sure '),
                alertType: RichAlertType.WARNING,
                actions: <Widget>[
                  FlatButton(
                    child: Text("Yes"),
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                  ),
                  FlatButton(
                    child: Text("No"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
      },
      child: Scaffold(
        drawer: AppDrawer(),
        appBar: ElderlyAppBar(),
        body: SafeArea(
          child: StreamBuilder(
              stream: Firestore.instance
                  .collection('relatives')
                  .document(userID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Relative relative = Relative();
                  relative.getData(snapshot.data);
                  if (relative.elderUID == '' ||
                      relative.elderUID.isEmpty ||
                      relative.elderUID == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Link Account to continue'),
                          ),
                          RaisedButton(
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return LinkElder();
                                }));
                              },
                              color: Colors.green,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text('Link Now ')),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: <Widget>[
                      SizedBox(
                        height: screenHeight * 0.1,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                InkWell(
                                  splashColor: Colors.blue,
                                  child: CardButton(
                                    height: screenHeight * (20 / 100),
                                    width: screenWidth * (35 / 100),
                                    icon: FontAwesomeIcons.notesMedical,
                                    size: screenWidth * 0.2,
                                    color: Color(0xff3d5afe),
                                    borderColor:
                                        Color(0xff3d5afe).withOpacity(0.75),
                                  ),
                                  onTap: () {
//                            Navigator.push(context,
//                                MaterialPageRoute(builder: (_) {
//                                  return TrackerHome();
//                                }));
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text('Health Tracker'),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                InkWell(
                                  splashColor: Colors.brown,
                                  child: CardButton(
                                    height: screenHeight * (20 / 100),
                                    width: screenWidth * (35 / 100),
                                    icon: FontAwesomeIcons.fileAlt,
                                    size: screenWidth * 0.2,
                                    color: Color(0xff5d4037),
                                    borderColor:
                                        Color(0xff5d4037).withOpacity(0.75),
                                  ),
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (_) {
                                      return ViewDocuments(
                                          uid: relative.elderUID);
                                    }));
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text('Save Documents'),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: screenHeight * 0.06,
                      ),
                      Row(children: <Widget>[
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              InkWell(
                                splashColor: Colors.redAccent,
                                child: CardButton(
                                  height: screenHeight * 0.2,
                                  width: screenWidth * (35 / 100),
                                  icon: FontAwesomeIcons.userInjured,
                                  size: screenWidth * (25 / 100),
                                  color: Color(0xffD83B36),
                                  borderColor:
                                      Color(0xffD83B36).withOpacity(0.75),
                                ),
                                onTap: () async {
                                  bool granted =
                                      await checkRequiredPermission();
                                  if (granted) {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return VideoCall(
                                        userID: userID,
                                        elderID: relative.elderUID,
                                      );
                                    }));
                                  }
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text('Urgent Video Call'),
                              ),
                            ],
                          ),
                        ),
                      ])
                    ],
                  );
                } else
                  return Center(child: CircularProgressIndicator());
              }),
        ),
      ),
    );
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        setState(() {
          userID = loggedInUser.uid;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  String userID;
  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }
}
