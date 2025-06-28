import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/recipe_service.dart';
import '../models/recipe.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecipeService _recipeService = RecipeService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pastikan stream diinisialisasi dengan benar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  void _showAddRecipeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add New Recipe',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade800,
          ),
          textAlign: TextAlign.center,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Container(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Recipe Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.orange.shade50,
                    prefixIcon: Icon(Icons.food_bank, color: Colors.orange.shade800),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter recipe name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.orange.shade50,
                    prefixIcon: Icon(Icons.description, color: Colors.orange.shade800),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ingredientsController,
                  decoration: InputDecoration(
                    labelText: 'Ingredients (comma separated)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.orange.shade50,
                    prefixIcon: Icon(Icons.list, color: Colors.orange.shade800),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter ingredients';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: _submitRecipe,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Add Recipe',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _submitRecipe() async {
    if (_formKey.currentState!.validate()) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        final recipe = Recipe(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          description: _descriptionController.text,
          ingredients: _ingredientsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          userId: userId,
        );

        try {
          // Tampilkan indikator loading
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Adding recipe...'),
                duration: Duration(seconds: 1),
              ),
            );
          }
          
          // Tambahkan resep ke database
          await _recipeService.addRecipe(recipe);
          
          // Reset form dan tutup dialog
          if (context.mounted) {
            _nameController.clear();
            _descriptionController.clear();
            _ingredientsController.clear();
            
            // Tutup dialog dan tampilkan konfirmasi sukses
            Navigator.of(context).pop();
            
            // Beri feedback ke user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Resep "${_nameController.text}" berhasil ditambahkan'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
            
            // Trigger setState untuk memastikan UI diperbarui
            if (mounted) setState(() {});
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userId = authProvider.currentUser?.id;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.orange.shade800,
            elevation: 0,
            title: Text(
              'My Recipes',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  authProvider.signOut();
                },
              ),
            ],
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.orange.shade100, // Warna lebih gelap sedikit di bagian atas
                  Colors.white,
                ],
                stops: const [0.0, 0.3],
              ),
            ),
            child: userId == null
                ? const Center(child: Text('Please login to view recipes'))
                : StreamBuilder<List<Recipe>>(
                    stream: _recipeService.getUserRecipes(userId),
                    key: ValueKey<String>('recipes-stream-$userId'), // Key unik untuk memaksa rebuild
                    builder: (context, snapshot) {
                      // Handle error state
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 60,
                                color: Colors.red[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading recipes',
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  color: Colors.red[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${snapshot.error}',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Handle loading state
                      if (!snapshot.hasData) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Loading recipes...',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Handle empty state
                      final recipes = snapshot.data!;
                      if (recipes.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No recipes yet. Add your first recipe!',
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      // Display recipes
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80), // Padding bawah lebih besar untuk FAB
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = recipes[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          recipe.name,
                                          style: GoogleFonts.playfairDisplay(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange.shade800,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red.shade300,
                                        ),
                                        onPressed: () async {
                                          try {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text(
                                                  'Confirm Delete',
                                                  style: GoogleFonts.playfairDisplay(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.orange.shade800,
                                                  ),
                                                ),
                                                content: Text(
                                                  'Are you sure you want to delete "${recipe.name}"?',
                                                  style: GoogleFonts.lato(),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      try {
                                                        Navigator.pop(context);
                                                        await _recipeService.deleteRecipe(recipe.id);
                                                        
                                                        // Trigger setState untuk memperbarui UI setelah penghapusan
                                                        if (mounted) setState(() {});
                                                        
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Row(
                                                              children: [
                                                                Icon(Icons.check_circle, color: Colors.white),
                                                                SizedBox(width: 8),
                                                                Text('Resep "${recipe.name}" berhasil dihapus'),
                                                              ],
                                                            ),
                                                            backgroundColor: Colors.green,
                                                            behavior: SnackBarBehavior.floating,
                                                            duration: Duration(seconds: 2),
                                                          ),
                                                        );
                                                      } catch (e) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Error: $e')),
                                                        );
                                                      }
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.red.shade400,
                                                    ),
                                                    child: Text(
                                                      'Delete',
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(e.toString())),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    recipe.description,
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Ingredients:',
                                    style: GoogleFonts.lato(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...recipe.ingredients.map((ingredient) => Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '• ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.orange.shade800,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                ingredient,
                                                style: GoogleFonts.lato(fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddRecipeDialog,
            backgroundColor: Colors.orange.shade800,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _recipeService.dispose(); // Panggil dispose pada RecipeService
    super.dispose();
  }
}
