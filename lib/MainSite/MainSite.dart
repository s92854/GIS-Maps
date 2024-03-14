import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'SearchThemesGoogle.dart';

class MainSite extends StatefulWidget {
  const MainSite({super.key});

  @override
  State<MainSite> createState() => _MainSiteState();
}

LinearGradient _backgroundGradiant = LinearGradient(colors: [Colors.blueAccent.shade200, Colors.lightGreen.shade500],begin: Alignment.topLeft, end: Alignment.bottomRight);
bool isThirdTileVisible = false;
String gitid = 's92854';
String gitname = 'GIS-Maps';
String appname = 'GIS-Maps';
String author = 'Nico Haupt';


class _MainSiteState extends State<MainSite> {

  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[

    Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: _backgroundGradiant
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 40),
            Image.asset('assets/mapIcon_1024.png', height: 150, width: 150),
            SizedBox(height: 45),
            Text('Willkommen bei $appname',
              style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),),
            SizedBox(height: 25.0),
            Text(
              '$appname ist eine einfache Kartenanwendung auf Basis der Google Maps Services. Sie enthält Geocoding und Geolokalisierungsfeatures.\nUm den vollen Funktionsumfang zu nutzen, gewähre der App Zugriff auf deinen Standort.\nWeitere Informationen im "Infos" Tab.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 18.0),),
            SizedBox(height: 20.0,),
            RichText(textAlign: TextAlign.center,
              text: TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: 'Die untere Leiste ermöglicht den einfachen Wechsel zwischen den verschiedenen Seiten.',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Image.asset('assets/bht_anthrazit.png', height: 120, width: 300, alignment: Alignment.bottomCenter,),
          ],
        ),
      ),
    ), // Homepage
    ThemesAndPlaces(), // Suche
    Scaffold( //Infopage
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 50),
            Text('Über $appname',
              style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),),
            SizedBox(height: 35.0),
            Text(
              'Diese App wurde von $author im 3. Semester an der BHT als Abschlussprojekt für das Modul Geoinformatik erstellt.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0),),
            SizedBox(height: 20.0,),
            Text(
              'Als Karten-, Geocoding- und Geolokalisierungsservice werden die Google-APIs verwendet.\nDer gesamte Quellcode ist auf Github zu finden. Als Programmiersprache wurde Flutter verwendet.\nEs erfolgt kein weiterer Support für die App.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0),),
            SizedBox(height: 40),
            Image.asset('assets/github.png', width: 100, height: 100),
            SizedBox(height: 5.0),
            Text(
              'https://github.com/$gitid/$gitname', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0),),
            SizedBox(height: 112.0),
            Image.asset('assets/bht_anthrazit.png', alignment: Alignment.bottomCenter,
                width: 300,
                height: 75),
          ],
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(child: Scaffold(
        appBar: AppBar(
          title: Text("$appname", softWrap: true,),
          centerTitle: true,
          clipBehavior: Clip.antiAlias,
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(blurRadius: 20,
                color: Colors.black.withOpacity(0.1),)
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: GNav(
                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[100]!,
                gap: 8,
                activeColor: Colors.blueAccent,
                iconSize: 24,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                tabBackgroundColor: Colors.grey[100]!,
                color: Colors.black,
                tabs: [
                  GButton(icon: Icons.home, text: "Home",),
                  GButton(icon: Icons.search, text: "Suche",),
                  GButton(icon: Icons.info, text: "Info",),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}