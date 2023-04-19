import 'dart:developer';

import 'package:flutter/material.dart';

import 'sliding_navigation/sliding_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Sheet Navigation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyAppp(),
    );
  }
}

class MyAppp extends StatelessWidget {
  const MyAppp({super.key});

  @override
  Widget build(BuildContext context) {
    PageChangerController pageChanger =
        PageChangerController(PageChangeService());
    var activeColor = Colors.blue;
    var notActiveColor = Colors.black;
    return Scaffold(
      body: SlidingNavigation(
        pageChanger: pageChanger,
        children: const [Widget1(), Widget2(), Widget3(), Widget2()],
      ),
      bottomSheet: StreamBuilder<double>(
          stream: pageChanger.listenToPagePositionStream,
          builder: (context, snapshot) {
            return Stack(
              children: [
                Positioned(
                    left: snapshot.data == null ? 0 : snapshot.data! / 4,
                    top: 3,
                    child: Container(
                      width: 70,
                      height: 3,
                      color: activeColor,
                    )),
                ButtonBar(alignment: MainAxisAlignment.spaceBetween, children: [
                  IconButton(
                      onPressed: () {
                        pageChanger.changePage(0);
                      },
                      icon: Icon(
                        Icons.ac_unit_outlined,
                        color: pageChanger.index != 0
                            ? notActiveColor
                            : activeColor,
                      )),
                  IconButton(
                      onPressed: () {
                        pageChanger.changePage(1);
                      },
                      icon: Icon(
                        Icons.accessible,
                        color: pageChanger.index != 1
                            ? notActiveColor
                            : activeColor,
                      )),
                  IconButton(
                      onPressed: () {
                        pageChanger.changePage(2);
                      },
                      icon: Icon(
                        Icons.account_tree_rounded,
                        color: pageChanger.index != 2
                            ? notActiveColor
                            : activeColor,
                      )),
                  IconButton(
                      onPressed: () {
                        pageChanger.changePage(3);
                      },
                      icon: Icon(
                        Icons.abc_outlined,
                        color: pageChanger.index != 3
                            ? notActiveColor
                            : activeColor,
                      )),
                ]),
              ],
            );
          }),
    );
  }
}

class Widget1 extends StatelessWidget {
  const Widget1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget 1'),
      ),
      body: ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) {
          final number = index + 1;
          return Card(
            color: Colors.red,
            child: ListTile(
              title: Center(child: Text('$number')),
            ),
          );
        },
      ),
    );
  }
}

class Widget2 extends StatelessWidget {
  const Widget2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget 2'),
      ),
      backgroundColor: Colors.deepPurple,
      body: const Center(
        child: Text(
          'This is Widget 2',
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}

class Widget3 extends StatelessWidget {
  const Widget3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget 3'),
      ),
      body: const Center(
        child: Text(
          'This is Widget 3',
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}
