import 'package:exodus/core/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/services/socket_service.dart';
import '../../core/utils/debug_logger.dart';
import '../../data/models/ticket/ticket_model.dart';

class MapScreen extends StatefulWidget {
  final List<TicketModel> tickets;
  const MapScreen({super.key, required this.tickets});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  double? _latitude;
  double? _longitude;

  late String busId;

  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    busId = widget.tickets.first.bus.id;

    _initLocationService();
  }

  void _initLocationService() {
    LocationService().init();
    SocketService().joinBusLive(busId);

    SocketService().listenToLiveLocation(busId, (data) {
      dPrint('Received live location: $data');

      if (mounted) {
        setState(() {
          _latitude = data['lat'];
          _longitude = data['lng'];
        });

        // Move the map center to new location
        _mapController.move(LatLng(_latitude!, _longitude!), 15.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = _latitude != null && _longitude != null;

    return Scaffold(
      appBar: AppBar(title: const Text("Bus Live Location")),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(23.8103, 90.4125),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          if (hasLocation)
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(_latitude!, _longitude!),
                  width: 60,
                  height: 60,
                  child: Icon(
                    Icons.directions_bus,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
