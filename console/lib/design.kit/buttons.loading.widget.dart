import 'package:flutter/material.dart';
import './screens.dart' as screens;

// The custom button that handles the asynchronous state
class LoadingButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final Widget child;

  const LoadingButton(
    this.child, {
    super.key,
    required this.onPressed,
  });

  @override
  _LoadingButtonState createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;
  static const double _iconSize = 24.0;

  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  _handlePress() {
    if (_isLoading) {
      return;
    }

    // Update state to show loading spinner and disable the button
    setState(() {
      _isLoading = true;
    });

    // Execute the user's asynchronous function and await its completion
    widget.onPressed().whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _isLoading ? null : _handlePress,
      child: screens.Loading(
        widget.child,
        loading: _isLoading,
        overlay: const SizedBox(
          width: _iconSize,
          height: _iconSize,
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ),
      ),
    );
  }
}
