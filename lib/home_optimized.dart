import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yoo_katale/dashboard.dart';

class foodlistOptimedSearch extends StatefulWidget {
  @override
  _foodlistOptimedSearchState createState() => _foodlistOptimedSearchState();
}

class _foodlistOptimedSearchState extends State<foodlistOptimedSearch> {
  List<String> _favoriteFoods = [];
  String _searchQuery = '';

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

  void _onSearchQueryChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<QueryDocumentSnapshot> _filteredFoodItems(List<QueryDocumentSnapshot> foodItems) {
    if (_searchQuery.isEmpty) {
      return foodItems;
    }

    return foodItems.where((foodItem) =>
        (foodItem['item_name'] as String? ?? '').toLowerCase().contains(_searchQuery.toLowerCase())).toList();
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
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _onSearchQueryChanged,
              decoration: InputDecoration(
                labelText: 'Search by item name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('foods').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                List<QueryDocumentSnapshot> foodItems = snapshot.data!.docs;
                List<QueryDocumentSnapshot> filteredFoodItems = _filteredFoodItems(foodItems);

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
          ),
        ],
      ),
    );
  }
}
