import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartparking_mobile_application/shared/components/navigator-bar.dart';
import 'package:smartparking_mobile_application/shared/i18n.dart';
import '../components/reservation-list.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Tab labels are localized at build time so locale changes are reflected.
  int? driverId;
  bool _isLoading = true;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: Text(tr('reservations.title')),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(text: tr('reservations.upcoming')),
            Tab(text: tr('reservations.past')),
          ],
        ),
      ),
      body:
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : driverId == null
          ? Center(
        child: Text(tr('reservations.no_driver')),
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
