import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/components/navigator-bar.dart';
import '../models/review.entity.dart';
import '../services/review.service.dart';
import '../components/review_list.dart';
import '../components/create_review_form.dart';

class ReviewsView extends StatefulWidget {
  final int? parkingId;
  final String title;

  const ReviewsView({Key? key, this.parkingId, required this.title})
    : super(key: key);

  @override
  State<ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends State<ReviewsView> {
  final ReviewService _reviewService = ReviewService();
  late Future<List<Review>> _reviewsFuture;
  bool _isLoading = true;
  String? _error;
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (index == 1) {
        // Reviews
        Navigator.pushReplacementNamed(context, '/reviews');
      } else if (index == 2) {
        Navigator.pushReplacementNamed(context, '/reservations');
      } else if (index == 3) {
        Navigator.pushReplacementNamed(context, '/profile');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.parkingId != null) {
        // If parkingId is provided, get reviews for that parking
        _reviewsFuture = _reviewService.getAllByParkingId(widget.parkingId!);
      } else {
        // Otherwise, get the current user's reviews
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('userId');

        if (userId == null) {
          throw Exception("User ID not found. Please log in again.");
        }

        _reviewsFuture = _reviewService.getAllByDriverId(userId);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error al cargar reseñas',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(_error!),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _loadReviews,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
              : FutureBuilder<List<Review>>(
                future: _reviewsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error al cargar reseñas',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(snapshot.error.toString()),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: _loadReviews,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No hay reseñas disponibles',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: _loadReviews,
                            child: const Text('Actualizar'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ReviewList(
                      reviews: snapshot.data!,
                      scrollable: true,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                  );
                },
              ),
      floatingActionButton:
          widget.parkingId != null
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CreateReviewForm(
                            parkingId: widget.parkingId!,
                            parkingName: widget.title,
                            onReviewCreated: _loadReviews,
                          ),
                    ),
                  );
                },
                tooltip: 'Create Review',
                backgroundColor: Colors.blue,
                child: const Icon(Icons.rate_review),
              )
              : FloatingActionButton(
                onPressed: _loadReviews,
                tooltip: 'Refresh',
                child: const Icon(Icons.refresh),
              ),
      bottomNavigationBar: NavigatorBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
