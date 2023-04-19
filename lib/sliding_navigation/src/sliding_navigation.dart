import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'page_changer_controller.dart';

enum SlideDirection { left, right }

/// A widget that displays a set of children widgets and enables navigation between them by swiping left or right.
class SlidingNavigation extends StatefulWidget {
  /// Creates a new `SlidingNavigation` widget.
  ///
  /// [animationDuration] is the duration of the animation that occurs when the page changes.
  /// [children] is a list of widgets that will be displayed by the `SlidingNavigation`.
  /// [pageChanger] is a controller that is used to change the current page.
  const SlidingNavigation({
    Key? key,
    this.animationDuration,
    required this.children,
    required this.pageChanger,
  }) : super(key: key);

  /// The duration of the animation that occurs when the page changes.
  final Duration? animationDuration;

  /// The list of widgets that will be displayed by the `SlidingNavigation`.
  final List<Widget> children;

  /// A controller that is used to change the current page.
  final PageChangerController pageChanger;

  @override
  State<SlidingNavigation> createState() => _SlidingNavigationState();
}

/// The state class for the [SlidingNavigation] widget.
class _SlidingNavigationState extends State<SlidingNavigation>
    with SingleTickerProviderStateMixin {
  /// The current position of the sliding animation.
  double currentPosition = 0;

  /// The position of the drag gesture.
  double dragPosition = 0;

  /// Half of pi constant for calculations.
  double halfPi = math.pi / 2;

  /// Flag indicating if the widget has been initialized.
  bool isIntalised = false;

  /// The animation controller for the sliding animation.
  late AnimationController _controller;

  /// The animation for the sliding animation.
  late Animation<double> _animation;

  /// The direction of the sliding animation.
  SlideDirection slideDirection = SlideDirection.left;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller with the given duration or default value.
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration ?? const Duration(milliseconds: 100),
    );

    // Set the page count on the page changer controller.
    widget.pageChanger.setPageCount = widget.children.length;

    // Add a listener to the page changer controller to handle changes.
    widget.pageChanger.addListener(_handelPageChangerListener);

    // Add a listener to the animation controller to handle changes.
    _controller.addListener(_animationControllerListener);
  }

  /// Handles changes to the animation controller.
  void _animationControllerListener() {
    widget.pageChanger.setNewPagePositionInStream = _animation.value;
    if (_controller.isCompleted) {
      widget.pageChanger.setRelativeCurrentIndex = currentPosition;
    }
  }

  // Handles the listener for when the page changer index changes
  ///
  /// It calls the _handelScreenChange method with the current position of the screen
  /// and the target position of the new screen. It also updates the current position
  /// and resets the drag position to 0.
  void _handelPageChangerListener() {
    _handelScreenChange(currentPosition * widget.pageChanger.size.width,
        widget.pageChanger.index * widget.pageChanger.size.width);
    currentPosition = widget.pageChanger.index;
    dragPosition = 0;
  }

  /// Initializes the animation with the context size.
  ///
  /// If it has not been initialized yet, it sets isIntalised to true, and initializes the animation
  /// by creating a new Tween with a beginning value of 0.0 and an ending value of the
  /// 0.0.
  void _initialize(BuildContext context) {
    if (!isIntalised) {
      isIntalised = true;
      _animation = Tween<double>(
        begin: 0.0,
        end: 0.0,
      ).animate(_controller);
    }
  }

  /// Returns a list of the widget children, each positioned based on the current animation value.
  ///
  /// The position is calculated based on the animation value and the index of each widget. The widgets
  /// are returned as a list of Positioned widgets.
  List<Widget> _getPages(BuildContext context, Size size) {
    double position = size.width;
    return widget.children.map((page) {
      position -= size.width;
      return Positioned(
          right: _animation.value + position,
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: page));
    }).toList();
  }

  /// Handles the update of the screen position while the user is dragging it.
  ///
  /// It first sets the drag direction based on the details of the drag. If the drag is out of bounds,
  /// it returns without doing anything. Otherwise, it calls _handelScreenChange with the current
  /// position plus the drag position and the current position multiplied by the page changer size.
  /// If the slide direction is left, it adds the distance of the drag to the drag position. If it is
  /// right, it subtracts the distance of the drag from the drag position.
  void _onHorizontalDragUpdate(details) {
    //Set the drag direction
    _setDragDirection(details);

    //Trying to drag to where there is no screen
    if (_checkIfDragOutOfBound) {
      return;
    }

    _handelScreenChange(
        (currentPosition * widget.pageChanger.size.width) + dragPosition,
        (currentPosition * widget.pageChanger.size.width) + dragPosition);

    if (slideDirection == SlideDirection.left) {
      dragPosition += details.delta.distance;
      return;
    }
    //drag the screen to the right
    dragPosition -= details.delta.distance;
  }

  /// Sets the drag direction based on the details of the drag.
  ///
  /// If the drag is to the left, it sets the slideDirection to left. Otherwise, it sets it to right.
  void _setDragDirection(details) {
    slideDirection = SlideDirection.right;
    //drag the screen to the left
    if (details.delta.direction >= halfPi &&
        details.delta.direction <= math.pi) {
      slideDirection = SlideDirection.left;
    }
  }

  /// Returns true if the current screen is at the edge of the screen
  /// and the user is trying to drag it out of bounds.
  bool get _checkIfDragOutOfBound {
    return currentPosition == 0.0 && slideDirection == SlideDirection.right ||
        currentPosition == widget.children.length - 1 &&
            slideDirection == SlideDirection.left;
  }

  /// Handles the end of a horizontal drag gesture.
  ///
  /// Based on the drag direction, it either moves to the next or previous screen or stays on the current screen.
  /// It also updates the current page index of the page changer widget.
  void _onHorizontalDragEnd(DragEndDetails details) {
    var screenPosition = widget.pageChanger.size.width * currentPosition;
    switch (slideDirection) {
      case SlideDirection.left:
        _moveAutoLeft(screenPosition);
        break;
      case SlideDirection.right:
        _moveAutoRight(screenPosition);
        break;
    }
    widget.pageChanger.setCurrentPageIndex = currentPosition;
    _handelScreenChange((dragPosition + screenPosition),
        (currentPosition * widget.pageChanger.size.width));
    dragPosition = 0;
  }

  /// Moves to the previous screen if the drag distance is more than
  /// half of the screen width to the left.
  void _moveAutoRight(double screenPosition) {
    if (screenPosition - (widget.pageChanger.size.width / 2) >
        screenPosition + dragPosition) {
      currentPosition -= 1;
    }
  }

  /// Moves to the next screen
  /// if the drag distance is more than half of the screen width to the right.
  void _moveAutoLeft(double screenPosition) {
    if (dragPosition + screenPosition >
        (widget.pageChanger.size.width / 2) + screenPosition) {
      currentPosition += 1;
    }
  }

  /// Animates the transition from one screen to another.
  ///
  /// Resets the animation controller and sets the animation to move from the start position to the end position.
  /// It then starts the animation.
  void _handelScreenChange(double start, double end) {
    _controller.reset();
    _animation = Tween<double>(
      begin: start,
      end: end,
    ).animate(_controller);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    _initialize(context);
    var size = MediaQuery.of(context).size;
    widget.pageChanger.setSize = size;

    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              children: _getPages(context, size),
            );
          }),
    );
  }

  @override
  void dispose() {
    /// Disposes the animation controller and the page changer widget.
    _controller.dispose();
    widget.pageChanger.dispose();
    super.dispose();
  }
}
