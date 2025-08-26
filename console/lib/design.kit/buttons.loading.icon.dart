import 'package:flutter/material.dart';

// The custom button that handles the asynchronous state
class LoadingIconButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final Icon icon;

  const LoadingIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  _LoadingIconButtonState createState() => _LoadingIconButtonState();
}

class _LoadingIconButtonState extends State<LoadingIconButton> {
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
    // A button that is disabled when loading
    return IconButton(
      onPressed: _isLoading ? null : _handlePress,
      // Ternary operator to swap between the icon and the spinner
      icon:
          _isLoading
              ? const SizedBox(
                width: _iconSize,
                height: _iconSize,
                child: CircularProgressIndicator(strokeWidth: 2.0),
              )
              : widget.icon,
    );
  }
}
