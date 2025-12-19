import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/models_ecom/model_file.dart';
import 'package:furniture_ecom_app/core/services_ecom/cat_sub_banners.dart';
import 'package:furniture_ecom_app/my_ecom/categories.dart';
import 'package:furniture_ecom_app/my_ecom/subc_screen.dart';

import 'package:shimmer/shimmer.dart';

class MyCategoriesWidget extends StatefulWidget {
    final bool isPreview;

  const MyCategoriesWidget({super.key,  this.isPreview = false, });

  @override
  _MyCategoriesWidgetState createState() => _MyCategoriesWidgetState();
}

class _MyCategoriesWidgetState extends State<MyCategoriesWidget> {
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return FutureBuilder<List<Categorys>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return isTablet
              ? _buildTabletPlaceholder()
              : _buildMobilePlaceholder();
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return const Center(child: Text('No categories found'));
        }

        final categories = snapshot.data!;
        return isTablet
            ? _buildExploreSection(categories)
            : _buildExploreSection(categories);
      },
    );
  }

Widget _buildExploreSection(List<Categorys> categories) {
  final screenWidth = MediaQuery.of(context).size.width;
  final bool isTablet = screenWidth >= 600;
  final itemWidth = isTablet ? 120.0 : (screenWidth - 64) / 4;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Explore',
              style: TextStyle(
                fontSize: isTablet ? 20 : 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoriesScreen(isPreview: widget.isPreview,)),
                );
              },
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: isTablet ? 20 : 16,
                    color: Colors.grey[800],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: isTablet ? 170 : 110,
       
        child: ListView.separated(
  scrollDirection: Axis.horizontal,
  padding:  EdgeInsets.symmetric(horizontal:  isTablet ? 30 : 5),
  itemCount: categories.length,
  separatorBuilder: (context, index) =>
      SizedBox(width: isTablet ? 30 : 12), // 👈 adjust for tablet
  itemBuilder: (context, index) {
    return _buildCategoryItem(categories[index], itemWidth, isTablet);
  },
),

      ),
    ],
  );
}

  
  Widget _buildCategoryItem(Categorys category, double width, bool isTablet) {
  final String displayTitle = category.title.contains('&')
      ? category.title.split('&').first.trim()
      : category.title;

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubCategoryScreen(
            categoryId: category.id,
            wishlist: _wishlist,
            toggleWishlist: _toggleWishlist,
            isPreview: widget.isPreview,
          ),
        ),
      );
    },
    child: SizedBox(
      width: width,
      child: Column(
        children: [
          SizedBox(
            height: isTablet ? 110 : 60,
            width: isTablet ? 140 : 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                category.images[0],
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayTitle,
            style: TextStyle(
              fontSize: isTablet ? 18 : 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    ),
  );
}


  Widget _buildMobilePlaceholder() {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 50,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }




  Widget _buildTabletPlaceholder() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 140,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 100,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
