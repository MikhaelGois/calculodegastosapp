import 'package:flutter/material.dart';
import '../models/trip.dart';

class OverlayNotificationWidget extends StatefulWidget {
  final TripNotification notification;
  final VoidCallback onDismiss;
  final Duration displayDuration;

  const OverlayNotificationWidget({
    Key? key,
    required this.notification,
    required this.onDismiss,
    this.displayDuration = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  State<OverlayNotificationWidget> createState() =>
      _OverlayNotificationWidgetState();
}

class _OverlayNotificationWidgetState extends State<OverlayNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _startAutoClose();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  void _startAutoClose() {
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _animationController.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: GestureDetector(
        onTap: () {
          _animationController.reverse().then((_) {
            widget.onDismiss();
          });
        },
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.notification.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _animationController.reverse().then((_) {
                        widget.onDismiss();
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.notification.message,
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: 12,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gerenciador de notificações overlay
class OverlayNotificationManager {
  static final OverlayNotificationManager _instance =
      OverlayNotificationManager._internal();

  factory OverlayNotificationManager() {
    return _instance;
  }

  OverlayNotificationManager._internal();

  OverlayEntry? _currentOverlayEntry;

  void showNotification(
    BuildContext context,
    TripNotification notification,
  ) {
    // Remove notificação anterior se existir
    _currentOverlayEntry?.remove();

    _currentOverlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 0,
          right: 0,
          left: 0,
          child: SafeArea(
            child: OverlayNotificationWidget(
              notification: notification,
              onDismiss: () {
                _currentOverlayEntry?.remove();
                _currentOverlayEntry = null;
              },
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_currentOverlayEntry!);
  }

  void dismissNotification() {
    _currentOverlayEntry?.remove();
    _currentOverlayEntry = null;
  }
}
