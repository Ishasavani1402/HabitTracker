import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habittracker/Screens/BottomNavbar/AddHabit.dart';
import 'package:habittracker/database/DB_helper.dart';

class Habitcategory extends StatefulWidget {
  const Habitcategory({super.key});

  @override
  State<Habitcategory> createState() => _HabitcategoryState();
}

class _HabitcategoryState extends State<Habitcategory> with SingleTickerProviderStateMixin {
  // Define the colors for the gradient
  final Color startColor = const Color(0xFF667eea);
  final Color endColor = const Color(0xFF764ba2);
  late AnimationController _animationController;
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  DB_helper? dbref;

  @override
  void initState() {
    super.initState();
    dbref = DB_helper.getInstance;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final fetchedCategories = await dbref!.getCategories();
      setState(() {
        categories = fetchedCategories;
        isLoading = false;
        _animationController.forward();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load categories: $e")),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor.withOpacity(0.9), endColor.withOpacity(0.9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Text(
                  "Choose a Category",
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.065,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Main content area with white background
              Expanded(
                child: Container(
                  width: screenWidth,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : categories.isEmpty
                        ? const Center(child: Text("No categories found"))
                        : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.03,
                        horizontal: screenWidth * 0.05,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final categoryName = category['name'] as String;
                        final categoryIcon = category['icon'] as IconData;

                        return FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(
                                (1 / categories.length) * index,
                                1.0,
                                curve: Curves.easeInOut,
                              ),
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Addhabit(
                                        category: categoryName,
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: startColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Icon(
                                          categoryIcon,
                                          color: startColor,
                                          size: screenWidth * 0.07,
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.05),
                                      Text(
                                        categoryName,
                                        style: GoogleFonts.poppins(
                                          fontSize: screenWidth * 0.045,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}