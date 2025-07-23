import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextFieldWidget extends StatefulWidget {
  final Function(String, List<String>) onSearch;
  final Function(String)? onTextChanged;
  final bool autoFocus;
  final String initialValue;
  final List<String> filters;

  const TextFieldWidget({
    super.key,
    required this.onSearch,
    this.onTextChanged,
    this.autoFocus = false,
    this.initialValue = '', required this.filters,
    
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late TextEditingController _controller;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(TextFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update text if initialValue changed from parent
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  void _onTextChanged() {
    if (widget.onTextChanged != null) {
      widget.onTextChanged!(_controller.text);
    }
  }

  Future<void> _openCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        // Here you would handle the image for ingredient recognition
        // For now, just show a snackbar
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera image captured! Image processing will be implemented.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleSearch() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      // Pass the current filters from the widget
      widget.onSearch(query, widget.filters);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Container(
      height: h * 0.06,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Camera button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openCamera,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: w * 0.12,
                height: h * 0.06,
                decoration: BoxDecoration(
                  color: const Color(0xFF637FE7),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(w * 0.04),
                    bottomLeft: Radius.circular(w * 0.04),
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: w * 0.06,
                ),
              ),
            ),
          ),
          // Search field
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autoFocus,
              onSubmitted: (_) => _handleSearch(),
              decoration: InputDecoration(
                hintText: 'Search ingredients...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: w * 0.04,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: w * 0.04),
              ),
            ),
          ),
          // Search button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleSearch,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: w * 0.12,
                height: h * 0.06,
                decoration: BoxDecoration(
                  color: const Color(0xFF637FE7),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(w * 0.04),
                    bottomRight: Radius.circular(w * 0.04),
                  ),
                ),
                child: Icon(Icons.search, color: Colors.white, size: w * 0.06),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class TextFieldWidget extends StatefulWidget {
//   final Function(String, List<String>) onSearch;
//   final Function(String)? onTextChanged;
//   final bool autoFocus;
//   final String initialValue;

//   const TextFieldWidget({
//     super.key,
//     required this.onSearch,
//     this.onTextChanged,
//     this.autoFocus = false,
//     this.initialValue = '',
//   });

//   @override
//   State<TextFieldWidget> createState() => _TextFieldWidgetState();
// }

// class _TextFieldWidgetState extends State<TextFieldWidget> {
//   late TextEditingController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController(text: widget.initialValue);
//     _controller.addListener(_onTextChanged);
//   }

//   void _onTextChanged() {
//     if (widget.onTextChanged != null) {
//       widget.onTextChanged!(_controller.text);
//     }
//   }

//   void _handleSearch() {
//     final query = _controller.text.trim();
//     if (query.isNotEmpty) {
//       widget.onSearch(query, []);
//     }
//   }


//   @override
//   void dispose() {
//     _controller.removeListener(_onTextChanged);
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final h = MediaQuery.of(context).size.height;

//     return Container(
//       height: h * 0.06,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Camera button
//           Material(
//             color: Colors.transparent,
//             child: InkWell(
//               onTap: () {},
//               borderRadius: BorderRadius.circular(15),
//               child: Container(
//                 width: w * 0.12,
//                 height: h * 0.06,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF637FE7),
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(w * 0.04),
//                     bottomLeft: Radius.circular(w * 0.04),
//                   ),
//                 ),
//                 child: Icon(
//                   Icons.camera_alt,
//                   color: Colors.white,
//                   size: w * 0.06,
//                 ),
//               ),
//             ),
//           ),
//           // Search field
//           Expanded(
//             child: TextField(
//               controller: _controller,
//               onSubmitted: (_) => _handleSearch(),
//               decoration: InputDecoration(
//                 hintText: 'Search ingredients...',
//                 hintStyle: TextStyle(
//                   color: Colors.grey[400],
//                   fontSize: w * 0.04,
//                 ),
//                 border: InputBorder.none,
//                 contentPadding: EdgeInsets.symmetric(horizontal: w * 0.04),
//               ),
//             ),
//           ),
//           // Search button
//           Material(
//             color: Colors.transparent,
//             child: InkWell(
//               onTap: _handleSearch,
//               borderRadius: BorderRadius.circular(15),
//               child: Container(
//                 width: w * 0.12,
//                 height: h * 0.06,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF637FE7),
//                   borderRadius: BorderRadius.only(
//                     topRight: Radius.circular(w * 0.04),
//                     bottomRight: Radius.circular(w * 0.04),
//                   ),
//                 ),
//                 child: Icon(Icons.search, color: Colors.white, size: w * 0.06),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// // import 'package:flutter/material.dart';



// // class TextFieldWidget extends StatefulWidget {
// //   final Function(String, List<String>) onSearch;
// //   final Function(String)? onTextChanged;
// //   final bool autoFocus;
// //   final String initialValue;

// //   const TextFieldWidget({
// //     super.key,
// //     required this.onSearch,
// //     this.onTextChanged,
// //     this.autoFocus = false,
// //     this.initialValue = '',
// //   });

// //   @override
// //   State<TextFieldWidget> createState() => _TextFieldWidgetState();
// // }

// // class _TextFieldWidgetState extends State<TextFieldWidget> {
// //   late TextEditingController _controller;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _controller = TextEditingController(text: widget.initialValue);
// //     _controller.addListener(_onTextChanged);
// //   }

// //   void _onTextChanged() {
// //     if (widget.onTextChanged != null) {
// //       widget.onTextChanged!(_controller.text);
// //     }
// //   }

// //   void _handleSearch() {
// //     final query = _controller.text.trim();
// //     if (query.isNotEmpty) {
// //       widget.onSearch(query, []);
// //     }
// //   }


// //   @override
// //   void dispose() {
// //     _controller.removeListener(_onTextChanged);
// //     _controller.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final w = MediaQuery.of(context).size.width;
// //     final h = MediaQuery.of(context).size.height;

// //     return Container(
// //       height: h * 0.06,
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(15),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.1),
// //             blurRadius: 10,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           // Camera button
// //           Material(
// //             color: Colors.transparent,
// //             child: InkWell(
// //               onTap: () {},
// //               borderRadius: BorderRadius.circular(15),
// //               child: Container(
// //                 width: w * 0.12,
// //                 height: h * 0.06,
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFF637FE7),
// //                   borderRadius: BorderRadius.only(
// //                     topLeft: Radius.circular(w * 0.04),
// //                     bottomLeft: Radius.circular(w * 0.04),
// //                   ),
// //                 ),
// //                 child: Icon(
// //                   Icons.camera_alt,
// //                   color: Colors.white,
// //                   size: w * 0.06,
// //                 ),
// //               ),
// //             ),
// //           ),
// //           // Search field
// //           Expanded(
// //             child: TextField(
// //               controller: _controller,
// //               onSubmitted: (_) => _handleSearch(),
// //               decoration: InputDecoration(
// //                 hintText: 'Search ingredients...',
// //                 hintStyle: TextStyle(
// //                   color: Colors.grey[400],
// //                   fontSize: w * 0.04,
// //                 ),
// //                 border: InputBorder.none,
// //                 contentPadding: EdgeInsets.symmetric(horizontal: w * 0.04),
// //               ),
// //             ),
// //           ),
// //           // Search button
// //           Material(
// //             color: Colors.transparent,
// //             child: InkWell(
// //               onTap: _handleSearch,
// //               borderRadius: BorderRadius.circular(15),
// //               child: Container(
// //                 width: w * 0.12,
// //                 height: h * 0.06,
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFF637FE7),
// //                   borderRadius: BorderRadius.only(
// //                     topRight: Radius.circular(w * 0.04),
// //                     bottomRight: Radius.circular(w * 0.04),
// //                   ),
// //                 ),
// //                 child: Icon(Icons.search, color: Colors.white, size: w * 0.06),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
