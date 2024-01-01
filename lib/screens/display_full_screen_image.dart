import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class DisplayFullScreenImage extends StatelessWidget {
  const DisplayFullScreenImage({super.key, required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          //   width: double.infinity,
          //   height: double.infinity,
          // child: Image.network(
          //   imageUrl,
          //   fit: BoxFit.cover,
          // ),
          child: PhotoView(
        imageProvider: NetworkImage(imageUrl),
      )),
    );
  }
}
