import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooking_recipe_app/models/recipe.dart';
import 'package:uuid/uuid.dart';

class RecipeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uuid = const Uuid();
  bool _isLoading = false;
  List<Recipe> _recipes = [];
  List<Recipe> _trendingRecipes = [];

  bool get isLoading => _isLoading;
  List<Recipe> get recipes => _recipes;
  List<Recipe> get trendingRecipes => _trendingRecipes;

  Future<void> createRecipe({
    required String userId,
    required String title,
    required String description,
    required List<String> ingredients,
    required List<String> steps,
    required String imageUrl,
    required String category,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      Recipe recipe = Recipe(
        id: uuid.v4(),
        userId: userId,
        title: title,
        description: description,
        ingredients: ingredients,
        steps: steps,
        imageUrl: imageUrl,
        category: category,
        createdAt: DateTime.now(),
        likes: 0,
        savedBy: [],
      );

      await _firestore.collection('recipes').doc(recipe.id).set(recipe.toJson());

      _recipes.add(recipe);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchRecipes() async {
    try {
      _isLoading = true;
      notifyListeners();

      QuerySnapshot recipesSnapshot = await _firestore
          .collection('recipes')
          .orderBy('createdAt', descending: true)
          .get();

      _recipes = recipesSnapshot.docs
          .map((doc) => Recipe.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchTrendingRecipes() async {
    try {
      _isLoading = true;
      notifyListeners();

      QuerySnapshot recipesSnapshot = await _firestore
          .collection('recipes')
          .orderBy('likes', descending: true)
          .limit(10)
          .get();

      _trendingRecipes = recipesSnapshot.docs
          .map((doc) => Recipe.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> likeRecipe({
    required String recipeId,
    required String userId,
  }) async {
    try {
      DocumentReference recipeRef = _firestore.collection('recipes').doc(recipeId);
      
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot recipeDoc = await transaction.get(recipeRef);
        
        if (recipeDoc.exists) {
          Recipe recipe = Recipe.fromJson(recipeDoc.data() as Map<String, dynamic>);
          List<String> savedBy = List<String>.from(recipe.savedBy);
          
          if (!savedBy.contains(userId)) {
            savedBy.add(userId);
            transaction.update(recipeRef, {
              'likes': recipe.likes + 1,
              'savedBy': savedBy,
            });
          }
        }
      });

      await fetchRecipes();
      await fetchTrendingRecipes();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      QuerySnapshot recipesSnapshot = await _firestore
          .collection('recipes')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + 'z')
          .get();

      return recipesSnapshot.docs
          .map((doc) => Recipe.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
