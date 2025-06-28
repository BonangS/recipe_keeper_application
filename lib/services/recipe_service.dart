import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe.dart';
import 'dart:async';

class RecipeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final StreamController<List<Recipe>> _recipeController = StreamController<List<Recipe>>.broadcast();

  // Getter untuk stream publik
  Stream<List<Recipe>> get recipeStream => _recipeController.stream;

  // Add a new recipe
  Future<void> addRecipe(Recipe recipe) async {
    try {
      await _supabase.from('recipes').insert(recipe.toMap());
      // Log success untuk debugging
      print('Recipe added successfully: ${recipe.id}');
      
      // Perbarui stream dengan memuat ulang data
      _subscribeToUserRecipes(recipe.userId);
    } catch (e) {
      print('Error adding recipe: $e');
      throw 'Failed to add recipe: $e';
    }
  }

  // Get all recipes for a user
  Stream<List<Recipe>> getUserRecipes(String userId) {
    // Inisialisasi subscription ke database 
    _subscribeToUserRecipes(userId);
    
    // Kembalikan stream yang dibuat di constructor
    return _supabase
        .from('recipes')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false) // Newest first
        .map((items) {
          final recipes = items.map((item) => Recipe.fromMap(item)).toList();
          // Update controller stream
          _recipeController.add(recipes);
          return recipes;
        });
  }
  
  // Metode helper untuk berlangganan perubahan pada resep pengguna
  void _subscribeToUserRecipes(String userId) async {
    try {
      print('Refreshing recipes for user: $userId');
      
      // Ambil data awal
      final data = await _supabase
          .from('recipes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      final recipes = data.map((item) => Recipe.fromMap(item)).toList().cast<Recipe>();
      print('Loaded ${recipes.length} recipes for user: $userId');
      
      // Kirim data awal ke stream
      _recipeController.add(recipes);
    } catch (e) {
      print('Error subscribing to recipes: $e');
      _recipeController.addError(e);
    }
  }

  // Update a recipe
  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await _supabase
          .from('recipes')
          .update(recipe.toMap())
          .eq('id', recipe.id);
      
      // Perbarui stream dengan memuat ulang data
      _subscribeToUserRecipes(recipe.userId);
    } catch (e) {
      throw 'Failed to update recipe: $e';
    }
  }
  
  // Dispose metode untuk membersihkan resources
  void dispose() {
    _recipeController.close();
  }

  // Delete a recipe
  Future<void> deleteRecipe(String recipeId) async {
    try {
      // Dapatkan userId terlebih dahulu untuk memperbarui stream
      final recipeData = await _supabase
          .from('recipes')
          .select('user_id')
          .eq('id', recipeId)
          .single();
      
      final userId = recipeData['user_id'] as String;
      
      // Hapus resep
      await _supabase.from('recipes').delete().eq('id', recipeId);
      
      // Log success untuk debugging
      print('Recipe deleted successfully: $recipeId');
      
      // Perbarui stream dengan memuat ulang data
      _subscribeToUserRecipes(userId);
    } catch (e) {
      print('Error deleting recipe: $e');
      throw 'Failed to delete recipe: $e';
    }
  }
}
