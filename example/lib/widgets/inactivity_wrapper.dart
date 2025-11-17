import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/services/inactivity_service.dart';

class InactivityWrapper extends StatefulWidget {
  // WIDGET
  final Widget child;
  // ENABLE TRACKING
  final bool enableTracking;

  // CONSTRUCTOR
  const InactivityWrapper({
    super.key,
    required this.child,
    this.enableTracking = true,
  });

  @override
  State<InactivityWrapper> createState() => _InactivityWrapperState();
}

class _InactivityWrapperState extends State<InactivityWrapper>
    with WidgetsBindingObserver {
  // INACTIVITY SERVICE
  final InactivityService _inactivityService = InactivityService();

  @override
  void initState() {
    super.initState();

    // ADD OBSERVER TO WIDGETS BINDING
    WidgetsBinding.instance.addObserver(this);

    // IF TRACKING IS ENABLED, START TRACKING
    if (widget.enableTracking) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _inactivityService.startTracking(context);
      });
    }
  }

  // REMOVE OBSERVER FROM WIDGETS BINDING
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityService.stopTracking();
    super.dispose();
  }

  // DID CHANGE APP LIFECYCLE STATE
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.enableTracking) {
      _inactivityService.resetTimer(context);
    } else if (state == AppLifecycleState.paused) {
      _inactivityService.stopTracking();
    }
  }

  // ON USER INTERACTION
  void _onUserInteraction() {
    if (widget.enableTracking && mounted) {
      _inactivityService.resetTimer(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableTracking) {
      return widget.child;
    }

    // USER ACTIONS
    return Listener(
      onPointerDown: (_) => _onUserInteraction(),
      onPointerMove: (_) => _onUserInteraction(),
      onPointerUp: (_) => _onUserInteraction(),
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
