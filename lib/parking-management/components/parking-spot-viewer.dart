import 'package:flutter/material.dart';
import '../models/parking.entity.dart';
import '../services/parking.service.dart';

class ParkingSpotViewer extends StatefulWidget {
  final Parking parking;
  final Function(Map<String, dynamic>?) onSpotSelected;

  const ParkingSpotViewer({
    super.key,
    required this.parking,
    required this.onSpotSelected,
  });

  @override
  State<ParkingSpotViewer> createState() => _ParkingSpotViewerState();
}

class _ParkingSpotViewerState extends State<ParkingSpotViewer> {
  final ParkingService _parkingService = ParkingService();
  List<dynamic> _parkingSpots = [];
  Map<String, dynamic>? _selectedSpot;
  List<List<Map<String, dynamic>>> _grid = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParkingSpots();
  }

  Future<void> _loadParkingSpots() async {
    try {
      final spots = await _parkingService.getParkingSpotsByParkingId(widget.parking.id);
      setState(() {
        _parkingSpots = spots;
        _initializeGrid();
        _populateGridWithSpots();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading spots: $e')),
      );
    }
  }

  void _initializeGrid() {
    _grid = [];
    for (int row = 0; row < widget.parking.totalRows; row++) {
      final rowArray = <Map<String, dynamic>>[];
      for (int col = 0; col < widget.parking.totalColumns; col++) {
        rowArray.add({
          'type': 'aisle',
          'label': '',
          'row': row,
          'col': col,
        });
      }
      _grid.add(rowArray);
    }
  }

  void _populateGridWithSpots() {
    for (final spot in _parkingSpots) {
      final row = spot['rowIndex'];
      final col = spot['columnIndex'];

      if (row >= 0 && row < widget.parking.totalRows &&
          col >= 0 && col < widget.parking.totalColumns) {
        _grid[row][col] = {
          'type': 'spot',
          'label': spot['label'] ?? '',
          'id': spot['id'],
          'row': row,
          'col': col,
          'status': spot['status'],
        };
      }
    }
  }

  void _selectCell(Map<String, dynamic> cell) {
    if (cell['type'] == 'aisle') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This is an aisle. Please select a parking spot.'),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _selectedSpot = null;
      });
      widget.onSpotSelected(null);
      return;
    }
    if (cell['status'] == 'OCCUPIED') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This spot is occupied. Please select another spot.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (cell['status'] == 'RESERVED') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This spot is reserved. Please select another spot.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _selectedSpot = cell;
    });
    widget.onSpotSelected(cell);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: _buildParkingGrid(),
            ),
          ),
        ),
        _buildLegend(),
      ],
    );
  }

  Widget _buildParkingGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(50),
        children: _grid.map((row) {
          return TableRow(
            children: row.map((cell) {
              Color cellColor;
              if (cell['type'] == 'aisle') {
                cellColor = const Color(0xFFD9D9D9); // Light gray aisle
              } else {
                switch (cell['status']) {
                  case 'AVAILABLE':
                    cellColor = const Color(0xFF3B82F6); // Blue available
                    break;
                  case 'RESERVED':
                    cellColor = const Color(0xFFE7DE2F); // Yellow reserved
                    break;
                  case 'OCCUPIED':
                    cellColor = Colors.red; // Red occupied
                    break;
                  default:
                    cellColor = Colors.grey;
                }
              }

              bool isSelected = _selectedSpot != null &&
                  _selectedSpot!['id'] == cell['id'];

              return TableCell(
                child: GestureDetector(
                  onTap: () => _selectCell(cell),
                  child: Container(
                    height: 50,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green : cellColor,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        cell['label'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem('Available', const Color(0xFF3B82F6)),
          const SizedBox(width: 16),
          _legendItem('Reserved', const Color(0xFFE7DE2F)),
          const SizedBox(width: 16),
          _legendItem('Occupied', Colors.red),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(label),
      ],
    );
  }
}
