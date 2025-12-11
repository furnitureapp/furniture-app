import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/models_ecom/model_file.dart';
import 'package:furniture_ecom_app/core/services_ecom/cat_sub_banners.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/drawer.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/new_appbar.dart';
import 'package:furniture_ecom_app/my_ecom/subc_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<Categorys>> _categoriesFuture;
  final Set<String> _wishlist = {};

  @override
  void initState() {
    super.initState();
    _categoriesFuture = CatSubBannersService.fetchCategories();
  }

  void _toggleWishlist(String productId) {
    setState(() {
      if (_wishlist.contains(productId)) {
        _wishlist.remove(productId);
      } else {
        _wishlist.add(productId);
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _categoriesFuture = CatSubBannersService.fetchCategories();
    });
    await _categoriesFuture;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: NewAppbar(title: 'Categories'),
      ),
      drawer: const CustomDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: mythemecolor,
        backgroundColor: const Color.fromARGB(255, 245, 240, 242),
        displacement: 40,
        strokeWidth: 2.5,
        child: FutureBuilder<List<Categorys>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: AnimationPage1());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final categories = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 4 : 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubCategoryScreen(
                              categoryId: category.id,
                              wishlist: _wishlist,
                              toggleWishlist: _toggleWishlist,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 5,
                        color: const Color.fromARGB(255, 248, 249, 248),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  category.images[0],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 8,
                              ),
                              child: Text(
                                category.title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else {
              return const Center(child: Text('No categories found'));
            }
          },
        ),
      ),
    );
  }
}
