import 'package:flutter/foundation.dart' as foundation;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_repository.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

import 'post.dart';
import 'post_repository.dart';

import 'user.dart';
import 'user_repository.dart';

double _salesTaxRate = 0.06;
double _shippingCostPerItem = 7;

class AppStateModel extends foundation.ChangeNotifier {
  // All the available Posts.
  List<Post> _availablePosts = [];
  LocationData? _currentLocation;
  User? _user;
  // The currently selected category of Posts.
  // Category _selectedCategory = Category.all;

  // The IDs and quantities of Posts currently in the cart.
  final _PostsInCart = <int, int>{};

  Map<int, int> get PostsInCart {
    return Map.from(_PostsInCart);
  }

  // Total number of items in the cart.
  int get totalCartQuantity {
    return _PostsInCart.values.fold(0, (accumulator, value) {
      return accumulator + value;
    });
  }

  // Category get selectedCategory {
  //   return _selectedCategory;
  // }

  // Totaled prices of the items in the cart.
  // double get subtotalCost {
  //   return _PostsInCart.keys.map((id) {
  //     // Extended price for Post line
  //     return getPostById(id).price * _PostsInCart[id]!;
  //   }).fold(0, (accumulator, extendedPrice) {
  //     return accumulator + extendedPrice;
  //   });
  // }

  // Total shipping cost for the items in the cart.
  double get shippingCost {
    return _shippingCostPerItem *
        _PostsInCart.values.fold(0.0, (accumulator, itemCount) {
          return accumulator + itemCount;
        });
  }

  // Sales tax for the items in the cart
  // double get tax {
  //   return subtotalCost * _salesTaxRate;
  // }

  // Total cost to order everything in the cart.
  // double get totalCost {
  //   return subtotalCost + shippingCost + tax;
  // }

  // Returns a copy of the list of available Posts, filtered by category.
  List<Post> getPosts() {
    return List.from(_availablePosts);
    // if (_selectedCategory == Category.all) {
    //   return List.from(_availablePosts);
    // } else {
    //   return _availablePosts.where((p) {
    //     return p.category == _selectedCategory;
    //   }).toList();
    // }
  }
  LocationData? getLoc() {
    return _currentLocation;
  }
  User? getUser() {
    return _user;
  }
  

  // Search the Post catalog
  // List<Post> search(String searchTerms) {
  //   return getPosts().where((Post) {
  //     return Post.name.toLowerCase().contains(searchTerms.toLowerCase());
  //   }).toList();
  // }

  // Adds a Post to the cart.
  void addPostToCart(int PostId) {
    if (!_PostsInCart.containsKey(PostId)) {
      _PostsInCart[PostId] = 1;
    } else {
      _PostsInCart[PostId] = _PostsInCart[PostId]! + 1;
    }

    notifyListeners();
  }

  // Removes an item from the cart.
  void removeItemFromCart(int PostId) {
    if (_PostsInCart.containsKey(PostId)) {
      if (_PostsInCart[PostId] == 1) {
        _PostsInCart.remove(PostId);
      } else {
        _PostsInCart[PostId] = _PostsInCart[PostId]! - 1;
      }
    }

    notifyListeners();
  }

  // Returns the Post instance matching the provided id.
  // Post getPostById(int id) {
  //   return _availablePosts.firstWhere((p) => p.id == id);
  // }

  // Removes everything from the cart.
  void clearCart() {
    _PostsInCart.clear();
    notifyListeners();
  }

  void loadPosts() async {
    _availablePosts = await PostRepository.fetchPosts();
    notifyListeners();
  }

  void updateLocation() async {
    _currentLocation = await LocationRepository.getLoc();
    notifyListeners();
  }

  Future<void> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('user');
    if (user != null) {
      final userJson = jsonEncode(user);
      // print(userJson);
      _user = User.fromJson(jsonDecode(user));
    }
    notifyListeners();
  }

  Future<void> getUpdatedUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final bearer = prefs.getString('bearerToken');
    _user = await UserRepository.getUserData(bearer);
    if (_user != null) {
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> userJson = User.toJson(_user!);
      // print('jsonEncode ${jsonEncode(userJson)}');
      prefs.setString('user', jsonEncode(User.toJson(_user!)));
    }
    notifyListeners();
  }
  Future<void> loginUser(String email, String password) async {
    String? bearer = await UserRepository.loginUser(email, password);
    _user = await UserRepository.getUserData(bearer);
    if (_user != null) {
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> userJson = User.toJson(_user!);
      // print('jsonEncode ${jsonEncode(userJson)}');
      prefs.setString('user', jsonEncode(User.toJson(_user!)));
    }
    
    notifyListeners();
  }

  Future<void> logoutUser() async {
    await UserRepository.logoutUser();
    _user = null;
    notifyListeners();
  }

  Future<Post?> uploadPost(
    String title, 
    String locationDesc, 
    String servings,
    String expiryTime,
    int userId,
    XFile image,
    LocationData locationData
  ) async {
    final post = await PostRepository.uploadPost(
      title, 
      locationDesc, 
      servings, 
      expiryTime, 
      userId, 
      image, 
      locationData
    );
    return post;
  }
  

  // Loads the list of available Posts from the repo.
  // void loadPosts() {
  //   _availablePosts = PostRepository.fetchPosts();
  //   notifyListeners();
  // }

  // void setCategory(Category newCategory) {
  //   _selectedCategory = newCategory;
  //   notifyListeners();
  // }
}
