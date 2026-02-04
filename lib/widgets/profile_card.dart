import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Golden Shamrock Theme Colors
    const goldColor = Color(0xFFFFD700);

    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Center(
      child: Card(
        elevation: 8,
        color: const Color(0xFF1E1E1E), // Dark card background
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: goldColor, width: 2)),
        child: Container(
          width: 300,
          height: 400,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: goldColor,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, size: 50, color: Colors.black)
                    : null,
              ),
              const SizedBox(height: 20),
              Text(
                user?.displayName ?? "Guest User",
                style: const TextStyle(
                  color: goldColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                user?.bio ?? "No bio available.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              if (user?.isPremium == true)
                const Chip(
                  label: Text("Premium Member"),
                  backgroundColor: goldColor,
                  labelStyle: TextStyle(color: Colors.black),
                  avatar: Icon(Icons.star, color: Colors.black),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
