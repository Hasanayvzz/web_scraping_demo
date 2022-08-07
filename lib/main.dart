import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

import 'kitap.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Home());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Kitap> kitaplar = [];
  bool isLoading = false;
  var url = Uri.parse(
      "https://www.kitapyurdu.com/index.php?route=product/category&filter_category_all=true&path=1_2&filter_in_stock=1&sort=publish_date&order=DESC&limit=50");

  var data;

  Future getData() async {
    setState(() {
      isLoading = true;
    });
    var res = await http.get(url);
    final body = res.body;
    final document = parser.parse(body);
    /*
    Resim bu şekilde çekiliyor
    * element.children[2].children[0].children[0].children[0].attributes["src"]
    Kitap İsmi => element.children[3].text
    Yayın Evi => element.children[4].text
    Yazar => element.children[5].text
    Fiyat => element.children[8].children[0].text


    */
    var response = document
        .getElementsByClassName("product-grid")[0]
        .getElementsByClassName("product-cr")
        .forEach((element) {
      setState(() {
        kitaplar.add(Kitap(
            element.children[2].children[0].children[0].children[0]
                .attributes["src"]
                .toString(),
            element.children[3].text.toString(),
            element.children[4].text.toString(),
            element.children[5].text.toString(),
            element.children[8].children[0].text.toString()));
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  void initState() {
    super.initState();

    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Web Scraping"),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.53,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 10),
                itemCount: kitaplar.length,
                itemBuilder: (context, index) => Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 6,
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(kitaplar[index].image),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                index.toString(),
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          kitaplar[index].kitapAdi,
                          style: _style(),
                        ),
                        Text(kitaplar[index].yayinEvi, style: _style()),
                        Text(kitaplar[index].yazar, style: _style()),
                        Text(kitaplar[index].fiyat, style: _style()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  TextStyle _style() {
    return const TextStyle(
      color: Colors.amber,
      fontSize: 15,
    );
  }
}
