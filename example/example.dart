import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Tap to Address Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GoogleMapsTapToAddress(),
    );
  }
}
class GoogleMapsTapToAddress extends StatefulWidget {
  const GoogleMapsTapToAddress({super.key});

  @override
  _GoogleMapsTapToAddressState createState() => _GoogleMapsTapToAddressState();
}

class _GoogleMapsTapToAddressState extends State<GoogleMapsTapToAddress>
    with SingleTickerProviderStateMixin {
  late GoogleMapController mapController;
  late LatLng _initialPosition;
  bool _loading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _tappedAddress;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return; // Handle permission denial
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _loading = false;
    });
  }

  Future<void> _onMapDoubleTap(LatLng tappedPoint) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      tappedPoint.latitude,
      tappedPoint.longitude,
    );

    String address = _formatAddress(placemarks.first);

    setState(() {
      _tappedAddress = address;
    });

    _animationController.forward();
  }

  Future<void> _saveAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_tapped_address', address);
  }

  Future<String?> _getLastSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_tapped_address');
  }

  String _formatAddress(Placemark placemark) {
    return '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _goToLastAddressScreen() async {
    String? lastAddress = await _getLastSavedAddress();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LastAddressScreen(address: lastAddress),
      ),
    );
  }

  void _handleSaveAddress() {
    if (_tappedAddress != null) {
      _saveAddress(_tappedAddress!);
      _animationController.reverse(); // Close the pop-up with animation
    }
  }

  void _handleCancel() {
    _animationController.reverse(); // Close the pop-up with animation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Tap to Address'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _goToLastAddressScreen,
          ),
        ],
      ),
      body: Stack(
        children: [
          _loading
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            onTap: (LatLng tappedPoint) {
              _onMapDoubleTap(tappedPoint);
            },
            mapType: MapType.normal,
          ),
          if (_tappedAddress != null)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'العنوان',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_tappedAddress!),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _handleSaveAddress,
                            child: const Text('حفظ'),
                          ),
                          ElevatedButton(
                            onPressed: _handleCancel,
                            child: const Text('إلغاء'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class LastAddressScreen extends StatelessWidget {
  final String? address;

  const LastAddressScreen({Key? key, this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Last Saved Address'),
      ),
      body: Center(
        child: address != null
            ? Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            address!,
            style: const TextStyle(fontSize: 18),
          ),
        )
            : const Text('No address saved yet.',
            style: TextStyle(fontSize: 18)),
      ),
    );
  }
}