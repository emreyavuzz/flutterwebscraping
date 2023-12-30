import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:url_launcher/url_launcher.dart';

class NewsItem {
  String title;
  String description;
  String link;

  NewsItem({
    required this.title,
    required this.description,
    required this.link,
  });
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      theme: ThemeData(
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<NewsItem> newsList = [];
  bool isLoading = true;

  Future<void> fetchNewsList() async {
    final response = await http.get(Uri.parse('https://www.donanimhaber.com/'));

    if (response.statusCode == 200) {
      final document = htmlParser.parse(response.body);
      final newsElements = document.querySelectorAll('.medya');

      for (var newsElement in newsElements) {
        final title = newsElement.querySelector('.baslik')?.text ?? '';
        final description = newsElement.querySelector('.aciklama')?.text ?? '';
        final href =
            newsElement.querySelector('.baslik')?.attributes['href'] ?? '';
        final link = "https://www.donanimhaber.com/" + href;

        final newsItem = NewsItem(
          title: title,
          description: description,
          link: link,
        );

        newsList.add(newsItem);
      }

      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception('Haber listesi yüklenirken hata oluştu');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNewsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Donanım Haber Gündem',
          style: TextStyle(
            color: Colors.white, // Yazı rengi
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo, // Arka plan rengi
        elevation: 0, // AppBar'ın gölge efektini kaldırır
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.indigo, Colors.blue],
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                return _buildNewsItem(newsList[index]);
              },
            ),
    );
  }

  Widget _buildNewsItem(NewsItem newsItem) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailPage(newsItem: newsItem),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              newsItem.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 8),
            Text(
              newsItem.description,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                launchUrl(Uri.parse(newsItem.link),
                    mode: LaunchMode.inAppWebView);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.indigo,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Devamını Oku'),
            ),
          ],
        ),
      ),
    );
  }
}

class NewsDetailPage extends StatelessWidget {
  final NewsItem newsItem;

  NewsDetailPage({required this.newsItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Haber Detayı'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              newsItem.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 16),
            Text(
              newsItem.description,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                launchUrl(Uri.parse(newsItem.link),
                    mode: LaunchMode.inAppWebView);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.indigo,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Devamını Oku'),
            ),
          ],
        ),
      ),
    );
  }
}
