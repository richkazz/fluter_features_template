import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'page_changer_service.dart';

enum PagePositionStreamIndexType { real, relative }

/// The controller class for the page changer widget. It provides the business logic
/// to manage the state of the widget and communicate with the [PageChangeService].
class PageChangerController with ChangeNotifier {
  PageChangerController(this._pageChangeService,
      {required this.pagePositionStreamIndexType});

  final PageChangeService _pageChangeService;
  final PagePositionStreamIndexType pagePositionStreamIndexType;

  /// Listener for the animation value, always between -[size.width] <= [_pagePositionStream] value >= [size.width]
  final StreamController<double> _pagePositionStream =
      StreamController<double>();

  /// The index of the current page.
  double _index = 0;

  /// The relative current index of the page.
  double _relativeCurrentIndex = 0;

  /// The total amount of pages.
  late int _pageCount;

  /// The size of the widget.
  late Size _size;

  /// Gets the current index of the page.
  double get index => _index;

  /// Gets the size of the widget.
  Size get size => _size;

  /// Changes the current page to the given index.
  ///
  /// If the index is greater than or equal to the page count, the function returns without doing anything.
  void changePage(int index) {
    if (index >= _pageCount) return;

    _index = index.toDouble();
    notifyListeners();
    _pageChangeService.changePage(index);
  }

  /// Sets the new page position in the stream.
  ///
  /// The `position` parameter is the new position of the page.
  set setNewPagePositionInStream(double position) =>
      pagePositionStreamIndexType == PagePositionStreamIndexType.real
          ? _pagePositionStream.add(position)
          : _pagePositionStream
              .add(position - (size.width * _relativeCurrentIndex));

  /// Gets the stream that listens to the page position.
  Stream<double> get listenToPagePositionStream => _pagePositionStream.stream;

  /// Closes the stream that listens to the page position.
  Future closePagePositionStream() => _pagePositionStream.close();

  /// Sets the current page index to the given index.
  set setCurrentPageIndex(double index) => _index = index;

  /// Sets the relative current index of the page.
  set setRelativeCurrentIndex(double index) => _relativeCurrentIndex = index;

  /// Sets the size of the widget.
  set setSize(Size size) => _size = size;

  /// Sets the page count to the given page count.
  set setPageCount(int pageCount) => _pageCount = pageCount;
}
