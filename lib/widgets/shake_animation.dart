import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

/// Shake animation widget for iOS-style delete interaction
class ShakeAnimationWidget extends StatefulWidget {
  final Widget child;
  final bool isShaking;
  final VoidCallback? onDelete;
  final Duration duration;

  const ShakeAnimationWidget({
    super.key,
    required this.child,
    this.isShaking = false,
    this.onDelete,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<ShakeAnimationWidget> createState() => _ShakeAnimationWidgetState();
}

class _ShakeAnimationWidgetState extends State<ShakeAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _showDeleteButton = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void didUpdateWidget(ShakeAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking != oldWidget.isShaking) {
      if (widget.isShaking) {
        _startShaking();
      } else {
        _stopShaking();
      }
    }
  }

  void _startShaking() {
    setState(() {
      _showDeleteButton = true;
    });
    _shakeController.repeat(reverse: true);
    HapticFeedback.mediumImpact();
  }

  void _stopShaking() {
    setState(() {
      _showDeleteButton = false;
    });
    _shakeController.stop();
    _shakeController.reset();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: widget.isShaking 
              ? Offset(_shakeAnimation.value * 0.5, _shakeAnimation.value * 0.3)
              : Offset.zero,
          child: Transform.rotate(
            angle: widget.isShaking ? _shakeAnimation.value * 0.02 : 0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                widget.child,
                if (_showDeleteButton && widget.onDelete != null)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onDelete?.call();
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Delete confirmation dialog with undo functionality
class DeleteConfirmationDialog extends StatelessWidget {
  final String itemName;
  final VoidCallback onConfirm;
  final VoidCallback? onUndo;

  const DeleteConfirmationDialog({
    super.key,
    required this.itemName,
    required this.onConfirm,
    this.onUndo,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String itemName,
    required VoidCallback onConfirm,
    VoidCallback? onUndo,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        itemName: itemName,
        onConfirm: onConfirm,
        onUndo: onUndo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Delete Photo?',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        'Are you sure you want to delete this photo from $itemName?',
        style: const TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop(true);
            
            // Show undo snackbar
            if (onUndo != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Photo deleted'),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: onUndo!,
                  ),
                  duration: const Duration(seconds: 5),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          child: const Text(
            'Delete',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// iOS-style photo card with shake animation
class AnimatedPhotoCard extends StatefulWidget {
  final String photoPath;
  final String photoId;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool enableShake;

  const AnimatedPhotoCard({
    super.key,
    required this.photoPath,
    required this.photoId,
    this.onTap,
    this.onDelete,
    this.enableShake = true,
  });

  @override
  State<AnimatedPhotoCard> createState() => _AnimatedPhotoCardState();
}

class _AnimatedPhotoCardState extends State<AnimatedPhotoCard> {
  bool _isShaking = false;

  void _toggleShake() {
    if (!widget.enableShake) return;
    
    setState(() {
      _isShaking = !_isShaking;
    });
  }

  void _handleDelete() async {
    if (widget.onDelete == null) return;
    
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      itemName: 'folder',
      onConfirm: widget.onDelete!,
    );
    
    if (confirmed == true) {
      setState(() {
        _isShaking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isShaking ? null : widget.onTap,
      onLongPress: widget.enableShake ? _toggleShake : null,
      child: ShakeAnimationWidget(
        isShaking: _isShaking,
        onDelete: _handleDelete,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(widget.photoPath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.error_outline,
                      size: 32,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}