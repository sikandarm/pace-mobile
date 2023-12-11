import 'package:com_a3_pace/services/get_all_contacts.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewContactsScreen extends StatefulWidget {
  const ViewContactsScreen({super.key});

  @override
  State<ViewContactsScreen> createState() => _ViewContactsScreenState();
}

class _ViewContactsScreenState extends State<ViewContactsScreen> {
  @override
  void initState() {
    callApiMethods();
    super.initState();
  }

  ContactList? contactApiData;
  bool isLoading = false;

  Future<void> callApiMethods() async {
    isLoading = true;
    contactApiData = await getAllContacts();
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to the last screen in the stack

            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "All Contacts",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Row(
            children: [
              // Padding(
              //   padding: const EdgeInsets.only(right: 10.0),
              //   child: Stack(
              //     children: [
              //       InkWell(
              //         onTap: () {
              //           // if (_blShowNotificationsList) {
              //           //   Navigator.push(
              //           //     context,
              //           //     MaterialPageRoute(
              //           //         builder: (context) =>
              //           //             const NotificationsScreen()),
              //           //   );
              //           // } else {
              //           //   showToast(
              //           //       "You do not have permission to see notifications.");
              //           // }
              //         },
              //         child: Image.asset(
              //           "assets/images/ic_bell.png",
              //           width: 32,
              //           height: 32,
              //         ),
              //       ),
              //       Positioned(
              //         top: 5,
              //         right: 0,
              //         child: Container(
              //           padding: const EdgeInsets.all(5),
              //           decoration: BoxDecoration(
              //             color: Colors.red,
              //             borderRadius: BorderRadius.circular(12),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // GestureDetector(
              //   onTap: () {
              //     // Navigator.push(
              //     //   context,
              //     //   MaterialPageRoute(
              //     //       builder: (context) => const ProfileScreen()),
              //     // );
              //   },
              //   child: const Padding(
              //     padding: EdgeInsets.only(right: 10.0, left: 5.0),
              //     child: CircleAvatar(
              //       backgroundImage: AssetImage('assets/images/ic_profile.png'),
              //       radius: 15,
              //     ),
              //   ),
              // ),
            ],
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () async {
      //   await getAllContacts();
      // }),

      body: Padding(
        padding: const EdgeInsets.all(11.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    for (int i = 0;
                        i < contactApiData!.data.contacts.length;
                        i++) ...{
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(21.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'First Name: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(contactApiData!
                                      .data.contacts[i].firstName!),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Last Name: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(contactApiData!
                                      .data.contacts[i].lastName!),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Email: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(contactApiData!.data.contacts[i].email!),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Contact No: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(contactApiData!
                                      .data.contacts[i].phoneNumber!),
                                ],
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              ElevatedButton.icon(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStatePropertyAll(Colors.green),
                                    foregroundColor:
                                        MaterialStatePropertyAll(Colors.white),
                                  ),
                                  onPressed: () async {
                                    await launchDialer(contactApiData!
                                        .data.contacts[i].phoneNumber!);
                                  },
                                  icon: Icon(
                                    Icons.call,
                                    size: 18,
                                  ),
                                  label: Text('Call')),
                            ],
                          ),
                        ),
                      ),
                    }
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> launchDialer(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    //if (await canLaunch(url)) {
    await launchUrl(Uri.parse(url));
    // }
    //  else {
    //  throw 'Could not launch $url';
  }
}
