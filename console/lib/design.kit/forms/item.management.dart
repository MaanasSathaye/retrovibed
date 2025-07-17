import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ItemListManager<T> extends StatefulWidget {
  final Future<T> Function(T) onSubmit;
  final Widget Function(T item) builder;

  const ItemListManager({
    super.key,
    required this.onItemsUpdated,
    required this.onAddItem,
    required this.builder,
  });

  @override
  _ItemListManagerState<T> createState() => _ItemListManagerState<T>();
}

class _ItemListManagerState<T> extends State<ItemListManager<T>> {
  final List<T> _items = [];
  late final FocusNode _focusNode;
  bool _isLoading = false;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleAddItem() async {
    setState(() {
      _isLoading = true;
      _isCancelled = false;
    });

    try {
      final item = await widget.onAddItem();
      if (!_isCancelled) {
        setState(() {
          _items.add(item);
        });
      } else {
        print('Operation cancelled, item discarded.');
      }
    } catch (e) {
      print('Failed to add item: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape &&
        _isLoading) {
      setState(() {
        _isCancelled = true;
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAddItem,
                  child: const Text('Add Item Asynchronously'),
                ),
              ),
              const SizedBox(width: 8.0),
              if (_isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
            ],
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return widget.itemBuilder(item);
              },
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () => widget.onItemsUpdated(_items),
            child: const Text('Update Parent'),
          ),
        ],
      ),
    );
  }
}