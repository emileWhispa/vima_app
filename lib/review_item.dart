import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vima_app/super_base.dart';

import 'json/review.dart';

class ReviewItem extends StatefulWidget {
  final Review review;

  const ReviewItem({super.key, required this.review});

  @override
  State<ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends Superbase<ReviewItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: widget.review.user.profile != null
              ? CachedNetworkImageProvider(widget.review.user.profile!)
              : null,
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.review.user.username ?? "",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontSize: 16),
                    ),
                  ),
                  Row(
                    children: [1, 2, 3, 4, 5]
                        .map((e) => Icon(
                      widget.review.review >= e ? Icons.star : Icons.star_border,
                              size: 13,
                              color: widget.review.review >= e
                                  ? Theme.of(context).primaryColor
                                  : null,
                            ))
                        .toList(),
                  )
                ],
              ),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(text: widget.review.description),
                    TextSpan(text: " . ${fmtDate(widget.review.createdAt)}",style: const TextStyle(
                      fontWeight: FontWeight.bold
                    ))
                  ]
                ),
              ),
            ],
          ),
        ))
      ],
    );
  }
}
