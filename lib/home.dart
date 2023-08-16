import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yoo_katale/chatwithagent.dart';
import 'package:yoo_katale/dashboard.dart';

class FoodListPage extends StatefulWidget {
  @override
  _FoodListPageState createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  List<String> _favoriteFoods = [];

  @override
  void initState() {
    _fetchFavoriteFoods(); // Fetch user's favorite foods from Firestore
    super.initState();
  }

  Future<void> _fetchFavoriteFoods() async {
    // Fetch user's favorite foods from Firestore based on their email
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(user.email).get();
      if (userSnapshot.exists) {
        String favoriteFoodsString = userSnapshot.data()!['favorite_foods'] as String;
        setState(() {
          _favoriteFoods = favoriteFoodsString.split(',').map((food) => food.trim()).toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food List'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage()),
              );
            },
            child: Text(
              'Add Food Item',
              style: TextStyle(color: Colors.white),
            ),
          ),
           TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatPage()),
              );
            },
            child: Text(
              'chat with agent',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('foods').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<QueryDocumentSnapshot> foodItems = snapshot.data!.docs;
          List<QueryDocumentSnapshot> filteredFoodItems = foodItems
              .where((foodItem) =>
                  _favoriteFoods.contains(foodItem['item_name'] as String? ?? ''))
              .toList();

          return RefreshIndicator(
            onRefresh: _fetchFavoriteFoods, // Refresh the favorite foods
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: filteredFoodItems.length,
              itemBuilder: (context, index) {
                var foodData = filteredFoodItems[index].data() as Map<String, dynamic>;

                return Card(
                  child: Column(
                    children: [
                      Expanded(
                        child: foodData['image_url'].isEmpty
                            ? Icon(Icons.fastfood) // Placeholder icon
                            : Image.network(foodData['image_url']),
                      ),
                      ListTile(
                        title: Text(foodData['item_name']),
                        subtitle: Text('\$${foodData['price']}'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
