import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final LatLng _center = const LatLng(25.612677, 85.158875);
  final Set<Marker> _markers = {};
  LatLng _lastMapPosition = const LatLng(25.612677, 85.158875);
  MapType _currentMapType = MapType.normal;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: MarkerId('id-1'),
        position: _center,
        infoWindow: InfoWindow(
          title: 'San Francisco',
          snippet: 'An interesting city',
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(_lastMapPosition.toString()),
          position: _lastMapPosition,
          infoWindow: InfoWindow(
            title: 'New Marker',
            snippet: 'Added by user',
          ),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.hybrid
          ? MapType.satellite
          : MapType.hybrid;

    });
  }


  void _searchAndNavigate() async {
    List<Location> locations = await locationFromAddress(_searchController.text);
    if (locations.isNotEmpty) {
      Location location = locations.first;
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(location.latitude, location.longitude),
        12.0,
      ));
      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId('searched-location'),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(
              title: _searchController.text,
              snippet: 'Searched location',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
        );
      });
    }
  }

  Widget _buildFloatingActionButton(IconData icon, VoidCallback onPressed) {
    return FloatingActionButton(
      onPressed: onPressed,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.white,
      child: Icon(icon, size: 36.0, color: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Maps in Flutter'),
        backgroundColor: Colors.green[700],
        elevation: 0.0,
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
            mapType: _currentMapType,
            markers: _markers,
            onCameraMove: _onCameraMove,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                children: <Widget>[
                  Container(
                    width: 250,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Enter city name',
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: _searchAndNavigate,
                          color: Colors.green,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                      ),
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.green[900],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  _buildFloatingActionButton(Icons.my_location, () {
                    mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _center,
                          zoom: 14.0,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
                  _buildFloatingActionButton(Icons.map, _onMapTypeButtonPressed),
                  SizedBox(height: 16.0),
                  _buildFloatingActionButton(Icons.add_location, _onAddMarkerButtonPressed),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
