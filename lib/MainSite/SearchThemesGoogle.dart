import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ThemesAndPlaces extends StatefulWidget {
  @override
  State<ThemesAndPlaces> createState() => _ThemesAndPlacesState();
}

String gAPI = 'API_KEY';

class _ThemesAndPlacesState extends State<ThemesAndPlaces> {

  // Definieren von Sichtbarkeiten
  bool isThirdTileVisible = false;
  bool isSuggestionsVisible = false;

  List<LatLng> _polylineCoordinates = [];

  String themeForMap = ''; // Leeren themeString erstellen, um Themes zu wechseln
  String tokenForSession = '37465'; // Geocoding Token

  // Erstellung des Uuid
  var uuid = const Uuid();
  List<dynamic> listForPlaces = [];

  // Definieren der versch. Controller
  TextEditingController _controller = TextEditingController();
  final Completer<GoogleMapController> _gMapController = Completer();
  GoogleMapController? _mapController;

  // Definieren der Marker
  Set<Marker> _markers = {};
  MapType _mapType = MapType.normal;
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(52.54432970969272, 13.35263030002268),
    zoom: 5,
  );

  final List<Marker> marker = [];
  final List<Marker> markerList = const[Marker(markerId: MarkerId('Initial'),position: LatLng(52.54493956012626, 13.354306644470789),infoWindow: InfoWindow(title: 'Home'))];

  // App Start
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      onModify();
    });
    packData();
    _loadCustomIcon();
  }

  // GPS-Berechtigungsabfrage
  Future<Position> getUserLocation() async {
    await Geolocator.requestPermission().then((value)
    {

    }).onError((error, stackTrace)
    {
      print('Error$error');
    });
    return await Geolocator.getCurrentPosition();
  }

  // Abfrage der Userlocation
  packData() {
    getUserLocation().then((value) async
    {
      print('My location');
      print('${value.latitude}, ${value.longitude}');

      // Erstellung des Markers, Zoom auf Position
      _markers.add(
          Marker(markerId: const MarkerId('Position'),
              position: LatLng(value.latitude, value.longitude),
              icon: currentLocationIcon ?? BitmapDescriptor.defaultMarker,
              infoWindow: const InfoWindow(
                title: 'Meine Position',
              ),
          ),
      );
      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude),
          zoom: 18
      );
      final GoogleMapController controller = await _gMapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      setState(() {

      });
    });
  }

  // Vorschläge, (reverse) Geocoding
  void makeSuggestion(String input) async {
    String googlePlacesAPIKey = '$gAPI';
    String groundURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$groundURL?input=$input&key=$googlePlacesAPIKey&sessiontoken=$tokenForSession';

    var responseResult = await http.get(Uri.parse(request)); // Suche
    var Resultdata = responseResult.body.toString();

    // Wenn erfolgreich, dann liefere Liste mit Vorschlägen zurück
    if (responseResult.statusCode == 200) {
      setState(() {
        listForPlaces = jsonDecode(responseResult.body.toString())['predictions'];
      });
      // Ansonsten Fehlermeldung
    } else {
      throw Exception('Showing data failed, Try Again');
    }
  }

  void onModify() {
    if (tokenForSession == null) {
      setState(() {
        tokenForSession = uuid.v4();
      });
    }
    makeSuggestion(_controller.text);
  }

  final Map<String, String> _themeAliases = {
    'Standard': 'themes/DefaultTheme.json',
    'Dunkel': 'themes/DarkTheme.json',
    'Aubergine': 'themes/AubergineTheme.json',
    'Nacht': 'themes/NightTheme.json',
    'Retro': 'themes/RetroTheme.json',
    'Silber': 'themes/SilverTheme.json',
    'Satellit': 'themes/SatelliteTheme.json',
  };

  // Funktion zum Anzeigen des Bottom Sheets mit Themen
  void _showThemePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          children: _themeAliases.keys.map((String themeName) {
            return ListTile(
              title: Text(themeName),
              onTap: () {
                _applyMapTheme(context, _themeAliases[themeName]!);
              },
            );
          }).toList(),
        );
      },
    );
  }

  // Ausgewähltes Theme anwenden
  void _applyMapTheme(BuildContext context, String themePath) {
    _gMapController.future.then((value) {
      if (themePath.contains('SatelliteTheme')) {
        _mapType = MapType.satellite;
      } else {
        _mapType = MapType.normal;
        DefaultAssetBundle.of(context).loadString(themePath).then((style) {
          value.setMapStyle(style);
        });
      }
    });
    setState(() {
      Navigator.pop(context);
    });

    Future<void> _addRoute(LatLng newMarkerPosition) async {
      LatLng myPosition = _markers
          .firstWhere((element) => element.markerId == MarkerId('Position'))
          .position;

      PointLatLng myPoint = PointLatLng(
          myPosition.latitude, myPosition.longitude);
      PointLatLng newPoint = PointLatLng(
          newMarkerPosition.latitude, newMarkerPosition.longitude);

      List<PointLatLng> polylinePoints = [];

      PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
        '$gAPI', // Google API Key
        myPoint,
        newPoint,
      );

      if (result.points.isNotEmpty) {
        polylinePoints = result.points;
        _polylineCoordinates.clear();
        for (var point in polylinePoints) {
          _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
        setState(() {});
      }
    }
  }

  BitmapDescriptor? currentLocationIcon;
  BitmapDescriptor? destinationIcon;

  Future<void> _loadCustomIcon() async {
    currentLocationIcon = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(92, 136)), 'assets/Pin_here_small.png',);
    setState(() {});

    destinationIcon = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(51, 130)), 'assets/Pin_target_small.png',);
    setState(() {});
  }

  // Seitenlayout
  @override
  Widget build(BuildContext context) {
  if (currentLocationIcon == null) {
  return CircularProgressIndicator();
  } else {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                _mapController = controller;
                _gMapController.complete(controller);
              });
            },
            mapType: _mapType,
            markers: _markers,
            polylines: {
              Polyline(
                polylineId: const PolylineId('route'),
                color: Colors.blue,
                width: 8,
                points: _polylineCoordinates,
                geodesic: true,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
                jointType: JointType.round,
              ),
            },
            onTap: (LatLng tappedPoint) async {
              // Entferne alte Route
              _polylineCoordinates.clear();
              // Setze neuen Marker
              setState(() {
                _markers.removeWhere((marker) => marker.markerId == MarkerId('targetMarker'));
                _markers.add(
                  Marker(
                    markerId: const MarkerId('targetMarker'),
                    position: tappedPoint,
                    icon: destinationIcon!,
                    infoWindow: const InfoWindow(
                      title: 'Ziel',
                    ),
                  ),
                );
              });
              // Berechne und zeichne Route
              await _addRoute(tappedPoint);
            },
          ),
          // Theme-Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 52),
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Tooltip(
                  message: "Google Map Theme auswählen",
                  child: ElevatedButton(
                    onPressed: () {
                      _showThemePicker(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text("Kartenstil auswählen"), //Icon(Icons.arrow_circle_up),
                  ),
                ),
              ),
            ),
          ),
          // Suchfeld
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextFormField(
                onTap: () {
                  setState(() {
                    isSuggestionsVisible = true;
                  });
                },
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Suchen',
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  border: InputBorder.none, // Keine Rahmenlinie
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
          ),
          // Suchergebnisse
          Positioned(
            top: 70,
            left: 20,
            right: 20,
            height: isSuggestionsVisible ? 225 : 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListView.builder(
                itemCount: listForPlaces.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () async {
                      // Warte auf Texteingabe durch Benutzer, bis locationFromAddress() ausgeführt wird
                      List<Location> locations = await locationFromAddress(
                        listForPlaces[index]['description'],
                      );

                      // Bei Klick auf eine Location wird LatLng übergeben
                      if (locations.isNotEmpty) {
                        final LatLng selectedLatLng = LatLng(
                          locations.last.latitude,
                          locations.last.longitude,
                        );

                        // Animation zu vorher ausgewählter Lat und Lng
                        _mapController!.animateCamera(
                          CameraUpdate.newLatLngZoom(selectedLatLng, 15),
                        );

                        // Erstellen eines Markers für Lat und Lon
                        Marker marker = Marker(
                          markerId: const MarkerId('selectedLocation'),
                          position: selectedLatLng,
                          infoWindow: const InfoWindow(title: 'Ausgewählter Ort'),
                        );

                        // Wieder Deaktivieren der Vorschlägebox und Platzieren des vorher erstellten Markers
                        setState(() {
                          _markers.clear();
                          _markers.add(marker);
                          isSuggestionsVisible = false;
                        });
                      }
                    },
                    title: Text(listForPlaces[index]['description']),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // Position aktualisieren Button
      floatingActionButton: Stack(
        children: [
          PositionedFAB(
            icon: Icons.location_on_outlined,
            onPressed: (){
              packData();
            },
            position: FloatingActionButtonPosition.BottomLeft,
            offset: Offset(25, 30),
            tooltipMessage: "Position aktualisieren",
          ),
        ],
      ),
    );
  }
  }

  Future<void> _addRoute(LatLng newMarkerPosition) async {
    LatLng myPosition = _markers
        .firstWhere((element) => element.markerId == MarkerId('Position'))
        .position;

    PointLatLng myPoint = PointLatLng(
        myPosition.latitude, myPosition.longitude);
    PointLatLng newPoint = PointLatLng(
        newMarkerPosition.latitude, newMarkerPosition.longitude);

    List<PointLatLng> polylinePoints = [];

    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
      '$gAPI', // Google API Key
      myPoint,
      newPoint,
    );

    if (result.points.isNotEmpty) {
      polylinePoints = result.points;
      _polylineCoordinates.clear();
      for (var point in polylinePoints) {
        _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      setState(() {});
    }
  }
}

enum FloatingActionButtonPosition { TopLeft, TopCenter, TopRight, BottomLeft, BottomCenter, BottomRight }

class PositionedFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final FloatingActionButtonPosition position;
  final Offset? offset;
  final String tooltipMessage;

  PositionedFAB({
    required this.icon,
    required this.onPressed,
    this.position = FloatingActionButtonPosition.BottomLeft,
    this.offset,
    required this.tooltipMessage,
  });

  @override
  Widget build(BuildContext context) {
    double? top;
    double? bottom;
    double? left;
    double? right;

    if (position == FloatingActionButtonPosition.TopLeft ||
        position == FloatingActionButtonPosition.TopCenter ||
        position == FloatingActionButtonPosition.TopRight) {
      top = offset?.dy;
    } else if (position == FloatingActionButtonPosition.BottomLeft ||
        position == FloatingActionButtonPosition.BottomCenter ||
        position == FloatingActionButtonPosition.BottomRight) {
      bottom = offset?.dy;
    }

    if (position == FloatingActionButtonPosition.TopLeft ||
        position == FloatingActionButtonPosition.BottomLeft) {
      left = offset?.dx;
    } else if (position == FloatingActionButtonPosition.TopRight ||
        position == FloatingActionButtonPosition.BottomRight) {
      right = offset?.dx;
    } else if (position == FloatingActionButtonPosition.TopCenter ||
        position == FloatingActionButtonPosition.BottomCenter) {
      left = offset?.dx;
      right = offset?.dx;
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: GestureDetector(
        onLongPress: () {
          _showTooltip(context);
        },
        child: Tooltip(
          message: tooltipMessage,
          child: FloatingActionButton(
            onPressed: onPressed,
            child: Icon(
              icon,
              color: Colors.white,
            ),
            backgroundColor: Colors.blue,
          ),
        ),
      ),
    );
  }

  void _showTooltip(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    final tooltip = Tooltip(
      message: tooltipMessage,
      verticalOffset: renderBox.size.height + 10,
      preferBelow: false,
      child: Container(),
    );

    OverlayEntry entry = OverlayEntry(
      builder: (context) =>
          Positioned(
            left: offset.dx,
            top: offset.dy + renderBox.size.height + 10,
            child: tooltip,
          ),
    );

    Overlay.of(context)!.insert(entry);
    Future.delayed(Duration(seconds: 2), () {
      entry.remove();
    });
  }
}