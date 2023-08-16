import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yoo_katale/sign.dart';
import 'package:yoo_katale/user_profile.dart';
import 'package:yoo_katale/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SharePage extends StatefulWidget {
  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }
  String _profilePictureUrl = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int sharingCount = 0;
final FirebaseAuth _auth = FirebaseAuth.instance;
  int rewardPoints = 0;
  bool isLoading = false;
  String userEmailDisplay = '';
  Future<void> fetchUserData() async {
    setState(() {
      isLoading = true;
    });

    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(user.email).get();
      if (userSnapshot.exists) {
        setState(() {
          sharingCount = userSnapshot['sharingCount'];
          rewardPoints = userSnapshot['rewardPoints'];
          isLoading = false;
          userEmailDisplay = user.email!;
        });
      }
    }
  }
 void shareAndEarn() async{
    String appLink = "Hey, I am using YooKatale \n Forget about going to the market.\n Enjoy discounts, never miss \n A meal, everything delivered \n Join here [ https://yourappwebsite.com ] \n YooKatale, Here for you ";
    Share.share(appLink, subject: "Check out this cool app!");

    // Update sharing count and reward points
    
    // setState(() {
    //   sharingCount++;
    //   rewardPoints += 10; // Assuming you reward 10 points per share
    // });
      // Update Firestore with the new sharing count
    User? user = _auth.currentUser;

    if (user != null) {
      setState(() {
        sharingCount++;
        rewardPoints += 10; // Assuming you reward 10 points per share
      });

      await _firestore.collection('users').doc(user.email).set({
        'sharingCount': sharingCount,
        'rewardPoints': rewardPoints,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Share the Yoo Katale Experience"),
        actions: [
          TextButton(
            onPressed: () {
              // Implement your sign-in logic here
              // For example, navigate to the sign-in page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: InkWell(
  onTap: () {
    // Navigate to the profile page here
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  },
  child: CircleAvatar(
    radius: 50,
    backgroundImage: _profilePictureUrl.isEmpty
        ? null // No background image for the icon
        : NetworkImage(_profilePictureUrl), // Display image from URL
    child: _profilePictureUrl.isEmpty
        ? Icon(Icons.person) // Icon when no profile picture
        : null,
  ),
),

          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "YOO Katale Products ",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            // Product selection dropdown or list here

            SizedBox(height: 20.0),
            // Text(
            //   "Write a Catchy Caption",
            //   style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            // ),
            SizedBox(height: 10.0),
            // TextField(
            //   decoration: InputDecoration(
            //     hintText: "Craft a captivating caption...",
            //     border: OutlineInputBorder(),
            //   ),
            //   maxLines: 3,
            // ),

            SizedBox(height: 20.0),
            Text(
              "Choose a Platform and Share Yoo katale to friends and family",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // IconButton(
                //   icon: Icon(Icons.facebook),
                //   onPressed: () {
                //     // Share on Facebook logic
                //   },
                // ),
                // IconButton(
                //   icon: Icon(Icons.twitter),
                //   onPressed: () {
                //     // Share on Instagram logic
                //   },
                // ),
                // IconButton(
                //   icon: Icon(Icons.twitter),
                //   onPressed: () {
                //     // Share on Twitter logic
                //   },
                // ),
                // Add more social media platform icons here
              ],
            ),

            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                shareAndEarn();
              // Get the link to your app
    //String appLink = "Hey, I am using YooKatale \n Forget about going to the market.\n Enjoy discounts, never miss \n A meal, everything delivered \n Join here [ https://yourappwebsite.com ] \n YooKatale, Here for you ";

    // Share the link
   // Share.share(appLink, subject: "Check out this app!");
                //Share.share('Download the UG blood donate app: https://ug-blood-donate.github.io/', subject: 'lets save life.');
              },
              child: Text("Share Now"),
            ),

              SizedBox(height: 20.0),
           ElevatedButton(
              onPressed: fetchUserData,
              child: Text("Check Earned Points"),
            ),
            SizedBox(height: 20.0),
            isLoading
                ? CircularProgressIndicator()
                : userEmailDisplay.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "$userEmailDisplay, you now have $rewardPoints points",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 10),
                          Text("Sharing Count: $sharingCount"),
                        ],
                      )
                    : SizedBox(), 
          ],
        ),
      ),
    );
  }
}



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: WidgetTree(),
    debugShowCheckedModeBanner: false,

  ));
}
