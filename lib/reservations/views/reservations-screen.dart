import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartparking_mobile_application/shared/components/navigator-bar.dart';
import '../components/reservation-list.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statusTabs = ['PRÓXIMAS', 'PASADAS'];
  int? driverId;
  bool _isLoading = true;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _loadDriverId();
  }

  Future<void> _loadDriverId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? id = prefs.getInt('userId');

      setState(() {
        driverId = id;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (index == 1) {
        // Reviews (reusing reviews view)
        Navigator.pushReplacementNamed(context, '/reviews');
      } else if (index == 2) {
        Navigator.pushReplacementNamed(context, '/reservations');
      } else if (index == 3) {
        Navigator.pushReplacementNamed(context, '/profile');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Mis Reservas'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(text: _statusTabs[0]), // Próximas
            Tab(text: _statusTabs[1]), // Pasadas
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : driverId == null
              ? const Center(
                child: Text('No driver ID found. Please log in again.'),
              )
              : TabBarView(
                controller: _tabController,
                children: [
                  // Próximas -> show confirmed/pending reservations
                  ReservationList(status: 'CONFIRMED', driverId: driverId!),
                  // Pasadas -> completed
                  ReservationList(status: 'COMPLETED', driverId: driverId!),
                ],
              ),
      bottomNavigationBar: NavigatorBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
