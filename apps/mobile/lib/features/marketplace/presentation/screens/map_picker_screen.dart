import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({
    this.initialLatitude,
    this.initialLongitude,
    super.key,
  });

  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _selected;

  @override
  void initState() {
    super.initState();
    _selected = LatLng(
      widget.initialLatitude ?? 7.8731,
      widget.initialLongitude ?? 80.7718,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose listing location'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selected),
            child: const Text('Use'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _selected,
                initialZoom: widget.initialLatitude == null ? 7.5 : 14,
                onTap: (_, point) => setState(() => _selected = point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'lk.agrilink.mobile',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selected,
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.location_pin,
                        size: 48,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${_selected.latitude.toStringAsFixed(6)}, '
                '${_selected.longitude.toStringAsFixed(6)}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
