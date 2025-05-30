import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cooking_recipe_app/providers/auth_provider.dart';
import 'package:cooking_recipe_app/providers/recipe_provider.dart';
import 'package:cooking_recipe_app/screens/auth/login_screen.dart';
import 'package:cooking_recipe_app/screens/home/widgets/recipe_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: user.profileImage.isNotEmpty
                              ? NetworkImage(user.profileImage)
                              : null,
                          child: user.profileImage.isEmpty
                              ? Text(
                                  user.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn('Recipes', '${user.savedRecipes.length}'),
                            _buildStatColumn('Followers', '${user.followers.length}'),
                            _buildStatColumn('Following', '${user.following.length}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'My Recipes'),
                        Tab(text: 'Saved Recipes'),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: Consumer<RecipeProvider>(
              builder: (context, recipeProvider, child) {
                final userRecipes = recipeProvider.recipes
                    .where((recipe) => recipe.userId == user.id)
                    .toList();
                final savedRecipes = recipeProvider.recipes
                    .where((recipe) => user.savedRecipes.contains(recipe.id))
                    .toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRecipeGrid(userRecipes),
                    _buildRecipeGrid(savedRecipes),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeGrid(List<dynamic> recipes) {
    return recipes.isEmpty
        ? Center(
            child: Text(
              'No recipes yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              return RecipeCard(recipe: recipes[index]);
            },
          );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
