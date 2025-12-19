import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/models_ecom/model_file.dart';
import 'package:furniture_ecom_app/core/services_ecom/cat_sub_banners.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/appbar.dart';
import 'package:furniture_ecom_app/my_ecom/product/product.dart';

class SubCategoryScreen extends StatefulWidget {
  final String categoryId;
  final Set<String> wishlist;
  final Function(String) toggleWishlist;
  final bool isPreview;

  const SubCategoryScreen({
    super.key,
    required this.categoryId,
    required this.wishlist,
    required this.toggleWishlist,
    this.isPreview = false,
  });

  @override
  _SubCategoryScreenState createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  late Future<List<SubCategory>> _subCategoriesFuture;

  @override
  void initState() {
    super.initState();
    _subCategoriesFuture = CatSubBannersService.fetchSubCategories(
      widget.categoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return Scaffold(
      appBar:  PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: MyAppbar(
          title: 'Sub Categories',
          isPreview: widget.isPreview, // ✅ PASS THROUGH
        ),
      ),
      body: FutureBuilder<List<SubCategory>>(
        future: _subCategoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: mythemecolor),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No subcategories found'));
          } else {
            final subCategories = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 4 : 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.9,
                ),
                itemCount: subCategories.length,
                itemBuilder: (context, index) {
                  final subCategory = subCategories[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductPage(
                            subCategoryId: subCategory.id,
                            isPreview: widget.isPreview,
                          ),
                        ),
                      );
                      //   MaterialPageRoute(
                      //     builder: (context) => ProductPage(subCategoryId: subCategory.id),
                      //   ),
                      // );
                    },
                    child: Card(
                      elevation: 5,
                      color: Colors.white,
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
                                subCategory.images.isNotEmpty
                                    ? subCategory.images[0]
                                    : '',
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
                              subCategory.title,
                              style: const TextStyle(
                                fontSize: 14,
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
          }
        },
      ),
    );
  }
}
