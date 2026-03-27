import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SlideRightRoute<T> extends PageRoute<T> with CupertinoRouteTransitionMixin<T> {
  final Widget page;
  final Duration duration;

  SlideRightRoute({required this.page, this.duration = const Duration(milliseconds: 300), super.settings, super.fullscreenDialog});

  @override
  Widget buildContent(BuildContext context) {
    return page;
  }

  @override
  String? get title => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  bool _isIOS(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  @override
  bool get popGestureEnabled => !isFirst;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    return nextRoute is MaterialPageRoute && !nextRoute.fullscreenDialog;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if (_isIOS(context)) {
      return super.buildTransitions(context, animation, secondaryAnimation, child);
    }

    return const ZoomPageTransitionsBuilder().buildTransitions(this, context, animation, secondaryAnimation, child);
  }
}

class SlideUpRoute<T> extends PageRoute<T> with CupertinoRouteTransitionMixin<T> {
  final Widget page;
  final Duration duration;

  SlideUpRoute({required this.page, this.duration = const Duration(milliseconds: 350), super.settings});

  @override
  Widget buildContent(BuildContext context) {
    return page;
  }

  @override
  String? get title => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  bool get popGestureEnabled => !isFirst;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final platform = Theme.of(context).platform;
    final bool isIOS = platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    final slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic));

    final styledChild = SlideTransition(position: slideAnimation, child: child);

    if (isIOS) {
      final controller = _getAnimationController(animation);

      return _InteractiveVerticalDrag(animationController: controller, child: styledChild);
    }

    return styledChild;
  }
}

AnimationController? _getAnimationController(Animation? animation) {
  if (animation is AnimationController) {
    return animation;
  }
  if (animation is ProxyAnimation) {
    return _getAnimationController(animation.parent);
  }

  return null;
}

class _InteractiveVerticalDrag extends StatefulWidget {
  final Widget child;
  final AnimationController? animationController;

  const _InteractiveVerticalDrag({required this.child, this.animationController});

  @override
  State<_InteractiveVerticalDrag> createState() => _InteractiveVerticalDragState();
}

class _InteractiveVerticalDragState extends State<_InteractiveVerticalDrag> {
  AnimationController? get _controller => widget.animationController;

  void _handleDragStart(DragStartDetails details) {
    Navigator.of(context).didStartUserGesture();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_controller == null) return;
    final double delta = details.primaryDelta! / MediaQuery.of(context).size.height;
    _controller!.value -= delta;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller == null) return;
    final double velocity = details.primaryVelocity ?? 0.0;

    final bool shouldPop = _controller!.value < 0.6 || velocity > 400;

    if (shouldPop) {
      Navigator.of(context).pop();
    } else {
      _controller!.forward(from: _controller!.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return widget.child;
    }

    return GestureDetector(behavior: HitTestBehavior.translucent, onVerticalDragStart: _handleDragStart, onVerticalDragUpdate: _handleDragUpdate, onVerticalDragEnd: _handleDragEnd, child: widget.child);
  }
}

class FadeRoute<T> extends PageRoute<T> with CupertinoRouteTransitionMixin<T> {
  final Widget page;
  final Duration duration;

  FadeRoute({required this.page, this.duration = const Duration(milliseconds: 300), super.settings});

  @override
  Widget buildContent(BuildContext context) {
    return page;
  }

  @override
  String? get title => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  bool get popGestureEnabled => !isFirst;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return super.buildTransitions(context, animation, secondaryAnimation, child);
    }
    return FadeTransition(opacity: animation, child: child);
  }
}

class SlideLeftRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  SlideLeftRoute({required this.page, this.duration = const Duration(milliseconds: 300), super.settings})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          );
        },
      );
}

class SlideDownRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  SlideDownRoute({required this.page, this.duration = const Duration(milliseconds: 300), super.settings})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          );
        },
      );
}

class EnterExitRoute<T> extends PageRouteBuilder<T> {
  final Widget exitPage;
  final Widget page;

  EnterExitRoute({required this.page, required this.exitPage, Duration duration = const Duration(milliseconds: 300), super.settings})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return Stack(
            children: <Widget>[
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.0, 0.0), end: const Offset(-1.0, 0.0)).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                child: exitPage,
              ),
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                child: child,
              ),
            ],
          );
        },
      );
}

class AdaptiveLayoutRoute<T> extends PageRoute<T> with CupertinoRouteTransitionMixin<T> {
  final Widget page;
  final Duration duration;

  AdaptiveLayoutRoute({required this.page, this.duration = const Duration(milliseconds: 300), super.settings});

  @override
  Widget buildContent(BuildContext context) {
    return page;
  }

  @override
  String? get title => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  bool get popGestureEnabled => !isFirst;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    if (isMobile) {
      final platform = Theme.of(context).platform;
      if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
        return super.buildTransitions(context, animation, secondaryAnimation, child);
      }

      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic)),
        child: child,
      );
    } else {
      return child;
    }
  }
}
