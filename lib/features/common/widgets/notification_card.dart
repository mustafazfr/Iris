import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String title;        // Başlık (ör. salon adı)
  final String message;      // Bildirim metni
  final String timeAgo;      // “5 dakika önce” gibi zaman
  final int badgeCount;      // Örneğin kaçıncı bildirim

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.badgeCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık + menu
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, size: 20),
                onPressed: () {
                  // Menü aç vs.
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Badge + mesaj
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Zaman bilgisi
          Text(
            timeAgo,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
