import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartparking_mobile_application/rating-and-review/services/review.service.dart';
import '../models/review.entity.dart';

class CreateReviewForm extends StatefulWidget {
  final int parkingId;
  final String parkingName;
  final Function? onReviewCreated;

  const CreateReviewForm({
    Key? key,
    required this.parkingId,
    required this.parkingName,
    this.onReviewCreated,
  }) : super(key: key);

  @override
  State<CreateReviewForm> createState() => _CreateReviewFormState();
}

class _CreateReviewFormState extends State<CreateReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _selectedRating = 0;
  bool _isSubmitting = false;
  String? _errorMessage;
  final ReviewService _reviewService = ReviewService();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate() || _selectedRating == 0) {
      if (_selectedRating == 0) {
        setState(() {
          _errorMessage = 'Please select a rating';
        });
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final userId = await _getUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _createReview(
        userId: userId,
        parkingId: widget.parkingId,
        comment: _commentController.text,
        rating: _selectedRating,
      );

      if (widget.onReviewCreated != null) {
        widget.onReviewCreated!();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to submit review: ${e.toString()}';
        _isSubmitting = false;
      });
    }
  }

  // This method will be implemented later
  Future<void> _createReview({
    required int userId,
    required int parkingId,
    required String comment,
    required int rating,
  }) async {
    // Implementation will be added later
    var data = {
      'driverId': userId,
      'parkingId': parkingId,
      'comment': comment,
      'rating': rating,
    };
    print(data);
    var response = await _reviewService.post(data);
    if (response.containsKey('error')) {
      throw Exception('Failed to create review');
    } else {
      // Successfully created review
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate ${widget.parkingName}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Rating',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              _buildRatingSelector(),
              if (_errorMessage != null && _selectedRating == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 12.0,
                    ),
                  ),
                ),
              const SizedBox(height: 16.0),
              const Text(
                'Your Comment',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _commentController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a comment';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              if (_errorMessage != null && _selectedRating > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 14.0,
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Submit Review',
                          style: TextStyle(fontSize: 16.0),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _selectedRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 40.0,
          ),
          onPressed: () {
            setState(() {
              _selectedRating = index + 1;
              _errorMessage = null;
            });
          },
        );
      }),
    );
  }
}
