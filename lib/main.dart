import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS App Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'GPS App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _serviceEnabled = false;
  bool isLoading = false;
  Position? _locationData;
  MapController controller = MapController(); 


  @override
  initState() {
    super.initState(); 
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getLocation();
    });
  }

  Future<bool> checkService() async {
      return await Geolocator.isLocationServiceEnabled();
  }

  Future<bool> checkPermission() async {
   var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }
    return true;
  }

  getLocation() async {
    bool permission = await checkPermission(); 
    _serviceEnabled = await checkService(); 
    setState(() {});
    if(_serviceEnabled && permission) {
    _locationData = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(_locationData.toString()); 
    controller.move(LatLng(_locationData?.latitude ?? 50, _locationData?.latitude ?? 50),10);
    setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:  FlutterMap(
        mapController: controller,
        options: const MapOptions(
          interactionOptions: InteractionOptions(
            pinchZoomThreshold: 100, 
            pinchZoomWinGestures: 1
          )
        ),
        children: [
          TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    
      ),
      LocationMarkerLayer(position: LocationMarkerPosition(latitude:  _locationData?.latitude ?? 50, longitude:  _locationData?.latitude ?? 50,  accuracy: _locationData?.accuracy ?? 0),
      style: const LocationMarkerStyle(
        marker: Icon(Icons.navigation, color: Colors.blue,)
      ),
      )
        ], 
      ),

      floatingActionButton: FloatingActionButton(onPressed: () {
        getLocation(); 
      }, 
    
      child: const  Icon(Icons.gps_fixed_rounded),
      ),
    );
  
  }
}
