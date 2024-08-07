import 'package:contacts_example/api/firestore_api.dart';
import 'package:contacts_example/contact_utils.dart';
import 'package:contacts_example/main.dart';
import 'package:contacts_example/page/home_page.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    askContactsPermission();
  }

  Future askContactsPermission() async {
    final permission = await ContactUtils.getContactPermission();
    switch (permission) {
      case PermissionStatus.granted:
        uploadContacts();
        break;
      case PermissionStatus.permanentlyDenied:
        goToHomePage();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).hintColor,
            content: Text('Please allow to "Upload Contacts"'),
            duration: Duration(seconds: 3),
          ),
        );
        break;
    }
  }

Future<void> uploadContacts() async {
    // Fetch contacts from device
    final contacts =
        (await ContactsService.getContacts(withThumbnails: false)).toList();

    // Upload contacts to Firestore
    await FirestoreApi.uploadContacts(contacts);

    for (var contact in contacts) {

      print('Contact Name: ${contact.displayName ?? 'No name available'}');

      final phones = contact.phones ?? [];
      if (phones.isNotEmpty) {
        for (var phone in phones) {
          print('Phone Number: ${phone.value ?? 'No phone number available'}');
        }
      } else {
        print('Phone Number: No phone number available');
      }

      final emails = contact.emails ?? [];
      if (emails.isNotEmpty) {
        for (var email in emails) {
          print('Email: ${email.value ?? 'No email available'}');
        }
      } else {
        print('Email: No email available');
      }

      print('---');
    }

    goToHomePage();
  }



  void goToHomePage() => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
        ModalRoute.withName('/'),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(MyApp.title),
      ),
      body: Container(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Spacer(),
                Text(
                  'Enable app permissions to upload contacts',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                Spacer(),
                Container(
                  height: 150,
                  child: Image.asset('assets/contacts.png'),
                ),
                SizedBox(height: 32),
                Text(
                  'Tap Allow when prompted',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Spacer(),
                const SizedBox(height: 32),
                buildButton(context, 'Upload Contacts', askContactsPermission),
                const SizedBox(height: 32),
                buildButton(context, 'Continue', goToHomePage),
              ]),
        ),
      ),
    );
  }

  Widget buildButton(
          BuildContext context, String text, VoidCallback onPressed) =>
      Container(
        height: 50,
        width: 170,
        child: MaterialButton(
          child: Text(
            text,
            style: TextStyle(fontSize: 16),
          ),
          onPressed: onPressed,
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          shape: StadiumBorder(),
          //shape: StadiumBorder(),
        ),
      );
}
