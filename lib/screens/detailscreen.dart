import 'package:flutter/material.dart';
import 'package:snap_chef_5/components/custom_clip_path.dart';
import 'package:snap_chef_5/components/ingredient_list.dart';
import 'package:snap_chef_5/models/bookmark_model.dart';
import 'package:snap_chef_5/components/bottom_nav_bar.dart';
import 'package:snap_chef_5/screens/home.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isBookmarked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfBookmarked();
  }

  // Check if recipe is already bookmarked
  Future<void> _checkIfBookmarked() async {
    try {
      final isBookmarked = await BookmarkService.isBookmarked(
        widget.item['id'],
      );
      setState(() {
        _isBookmarked = isBookmarked;
        _isLoading = false;
      });
    } catch (e) {
      //print('Error checking bookmark status: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Toggle bookmark status
  Future<void> _toggleBookmark() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool success;
      if (_isBookmarked) {
        // Remove from bookmarks
        success = await BookmarkService.removeBookmark(widget.item['id']);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recipe removed from bookmarks'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Add to bookmarks
        success = await BookmarkService.addBookmark(widget.item);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recipe saved to bookmarks'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      setState(() {
        _isBookmarked = !_isBookmarked;
        _isLoading = false;
      });
    } catch (e) {
      //print('Error toggling bookmark: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update bookmark'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item.containsKey('analyzedInstructions')) {
      if (widget.item['analyzedInstructions'] is List &&
          widget.item['analyzedInstructions'].isNotEmpty) {
        if (widget.item['analyzedInstructions'][0] is Map &&
            widget.item['analyzedInstructions'][0].containsKey('steps')) {}
      }
    }

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    int readyInMinutes = (widget.item['readyInMinutes'] ?? 0).toInt();

    // Extract ingredients and instructions
    List<String> instructions = extractInstructions(widget.item);
    List<Map<String, dynamic>> ingredients = extractIngredients(widget.item);

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      bottomNavigationBar: BottomNavBar(
        // Show as bookmarked if it's currently bookmarked, otherwise show as Home
        selectedItem: _isBookmarked ? 3 : 0,
        onTap: (int index) {
          // Navigate to the Home screen with the selected tab index
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Home(initialIndex: index)),
            (route) => false, // Remove all previous routes
          );
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: h * 0.44,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.item['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Back button
                Positioned(
                  top: h * 0.05,
                  left: w * 0.05,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: EdgeInsets.all(w * 0.02),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: const Color(0xFF637FE7),
                          size: w * 0.065,
                        ),
                      ),
                    ),
                  ),
                ),

                // Share button with increased distance from bookmark
                Positioned(
                  top: h * 0.05,
                  right: w * 0.20,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Share functionality
                      },
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: EdgeInsets.all(w * 0.02),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.share,
                          color: const Color(0xFF637FE7),
                          size: w * 0.065,
                        ),
                      ),
                    ),
                  ),
                ),
                // Bookmark button
                Positioned(
                  top: h * 0.05,
                  right: w * 0.05,
                  child:
                      _isLoading
                          ? CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 25,
                            child: SizedBox(
                              width: w * 0.05,
                              height: w * 0.05,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF637FE7),
                              ),
                            ),
                          )
                          : Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _toggleBookmark,
                              customBorder: const CircleBorder(),
                              child: Container(
                                padding: EdgeInsets.all(w * 0.02),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isBookmarked
                                      ? Icons.bookmark
                                      : Icons.bookmark_outline,
                                  color: const Color(0xFF637FE7),
                                  size: w * 0.065,
                                ),
                              ),
                            ),
                          ),
                ),
                // Gradient overlay at the bottom of the image for a smooth transition
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: h * 0.05,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.grey.shade200],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: h * 0.02),
                  Center(
                    child: Text(
                      widget.item['title'],
                      style: TextStyle(
                        fontSize: w * 0.065,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  SizedBox(height: h * 0.01),
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.04,
                        vertical: h * 0.006,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF637FE7), // Deep Blue
                        borderRadius: BorderRadius.circular(w * 0.04),
                      ),
                      child: Text(
                        "Ready in $readyInMinutes min",
                        style: TextStyle(
                          fontSize: w * 0.035,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.04),

                  // Ingredients Section Title
                  _buildSectionTitle('Ingredients - ${ingredients.length}'),
                  SizedBox(height: h * 0.02),

                  // List of Ingredients
                  IngredientList(ingredients: ingredients),

                  SizedBox(height: h * 0.04),

                  // Instructions Section Title
                  _buildSectionTitle('Instructions'),
                  SizedBox(height: h * 0.02),

                  // List of Instructions
                  _buildInstructionsList(instructions),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return ClipPath(
      clipper: CustomClipPath(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: h * 0.012),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF637FE7),
              Color(0xFFF3756D),
            ], // Deep Blue to Salmon
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF637FE7).withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: w * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsList(List<String> instructions) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          instructions
              .map(
                (instruction) => Padding(
                  padding: EdgeInsets.symmetric(vertical: h * 0.005),
                  child: Text(
                    instruction,
                    style: TextStyle(fontSize: w * 0.04, color: Colors.black87),
                    overflow: TextOverflow.visible,
                  ),
                ),
              )
              .toList(),
    );
  }
}

List<Map<String, dynamic>> extractIngredients(Map<String, dynamic> item) {
  List<Map<String, dynamic>> extractedIngredients = [];
  Set<String> uniqueIngredients = {}; // To avoid duplicates

  // First try extendedIngredients if it exists
  if (item.containsKey('extendedIngredients') &&
      item['extendedIngredients'] != null &&
      item['extendedIngredients'] is List) {
    for (var ingredient in item['extendedIngredients']) {
      if (ingredient is Map<String, dynamic>) {
        String name = ingredient['name'] ?? ingredient['original'] ?? 'Unknown';

        // Only add if we haven't seen this ingredient before
        if (!uniqueIngredients.contains(name.toLowerCase())) {
          extractedIngredients.add({
            'name': name,
            'amount': ingredient['amount']?.toString() ?? '',
            'unit': ingredient['unit'] ?? '',
          });
          uniqueIngredients.add(name.toLowerCase());
        }
      }
    }
  }
  // Extract ingredients from analyzedInstructions if available
  else if (item.containsKey('analyzedInstructions') &&
      item['analyzedInstructions'] != null &&
      item['analyzedInstructions'] is List &&
      item['analyzedInstructions'].isNotEmpty) {
    for (var instruction in item['analyzedInstructions']) {
      if (instruction is Map<String, dynamic> &&
          instruction.containsKey('steps') &&
          instruction['steps'] is List) {
        for (var step in instruction['steps']) {
          if (step is Map<String, dynamic> &&
              step.containsKey('ingredients') &&
              step['ingredients'] is List) {
            for (var ingredient in step['ingredients']) {
              if (ingredient is Map<String, dynamic>) {
                String name = ingredient['name'] ?? 'Unknown';

                // Only add if we haven't seen this ingredient before
                if (!uniqueIngredients.contains(name.toLowerCase())) {
                  extractedIngredients.add({
                    'name': name,
                    'amount': '', // These might not be available in this format
                    'unit': '',
                  });
                  uniqueIngredients.add(name.toLowerCase());
                }
              }
            }
          }
        }
      }
    }
  }

  // Fallback: If no ingredients were found, provide a message
  if (extractedIngredients.isEmpty) {
    extractedIngredients.add({
      'name': 'No ingredients data available',
      'amount': '',
      'unit': '',
    });
  }

  return extractedIngredients;
}

List<String> extractInstructions(Map<String, dynamic> item) {
  List<String> instructions = [];

  // First try analyzedInstructions (structured data)
  if (item.containsKey('analyzedInstructions') &&
      item['analyzedInstructions'] != null &&
      item['analyzedInstructions'] is List &&
      item['analyzedInstructions'].isNotEmpty) {
    for (var instruction in item['analyzedInstructions']) {
      if (instruction is Map<String, dynamic> &&
          instruction.containsKey('steps') &&
          instruction['steps'] is List) {
        for (var step in instruction['steps']) {
          if (step is Map<String, dynamic> &&
              step.containsKey('number') &&
              step.containsKey('step')) {
            instructions.add('${step['number']}. ${step['step']}');
          }
        }
      }
    }
  }
  // Then try plain instructions (text data)
  else if (item.containsKey('instructions') &&
      item['instructions'] != null &&
      item['instructions'].toString().isNotEmpty) {
    // Split by periods or newlines to create steps
    String instructionsText = item['instructions'].toString();
    List<String> steps =
        instructionsText
            .split(RegExp(r'(?<=[.!?])\s+'))
            .where((step) => step.trim().isNotEmpty)
            .toList();

    for (int i = 0; i < steps.length; i++) {
      instructions.add('${i + 1}. ${steps[i].trim()}');
    }
  }
  // If neither is available, try to use the summary as a fallback
  else if (item.containsKey('summary') &&
      item['summary'] != null &&
      item['summary'].toString().isNotEmpty) {
    instructions.add("No detailed instructions available. Summary:");
    instructions.add(
      item['summary'].toString().replaceAll(RegExp(r'<[^>]*>'), ''),
    );
  }

  // Add a fallback message if no instructions were found
  if (instructions.isEmpty) {
    instructions.add("No instructions available.");
  }

  return instructions;
}
