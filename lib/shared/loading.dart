// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('Loading'),
      color: Colors.blue[200],
      child: const Center(
        child: SpinKitFadingFour(
          color: Colors.blue,
          // ignore: avoid_redundant_argument_values
          size: 50.0,
        ),
      ),
    );
  }
}
