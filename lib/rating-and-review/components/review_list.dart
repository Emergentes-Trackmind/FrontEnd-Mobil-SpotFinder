import 'package:flutter/material.dart';
import '../models/review.entity.dart';
import 'review_card.dart';

class ReviewList extends StatelessWidget {
  final List<Review> reviews;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;
  final Widget? emptyListWidget;

  const ReviewList({
    Key? key,
    required this.reviews,
    this.scrollable = true,
    this.padding,
    this.emptyListWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return emptyListWidget ??
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'No reviews available',
              style: TextStyle(
                fontSize: 16.0,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
        );
    }

    if (scrollable) {
      return ListView.builder(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: reviews.length,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return ReviewCard(review: reviews[index]);
        },
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: reviews.map((review) => ReviewCard(review: review)).toList(),
      );
    }
  }
}
