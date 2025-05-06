/* import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';
import '../screens/book_page_screen.dart';

class PageFlipScreen extends StatefulWidget {
  final int initialPage;
  final int totalPages;

  const PageFlipScreen({
    Key? key,
    required this.initialPage,
    required this.totalPages,
  }) : super(key: key);

  @override
  _PageFlipScreenState createState() => _PageFlipScreenState();
}

class _PageFlipScreenState extends State<PageFlipScreen> {
  final _flipKey = GlobalKey<PageFlipWidgetState>();

  @override
  void initState() {
    super.initState();
    // Переходимо на початкову сторінку після побудови
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _flipKey.currentState?.goToPage(widget.initialPage - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageFlipWidget(
        key: _flipKey,
        backgroundColor: Colors.white,
        lastPage: Container(
          color: Colors.white,
          child: const Center(child: Text('Кінець книги!')),
        ),
        children: List.generate(
          widget.totalPages,
          (index) => BookPageScreen(
            pageNumber: index + 1,
            isEmbedded: true,
          ),
        ),
      ),
    );
  }
}
 */