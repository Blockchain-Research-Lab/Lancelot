import 'package:flutter/material.dart';

class EventPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Details',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Event Name: Annual Tech Meetup',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Date: 25th August 2024',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Location: Conference Hall, Building A',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Description: A meetup for tech enthusiasts to discuss the latest trends in technology and networking opportunities.',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Perform some action
                print('Event action button pressed');
              },
              child: Text('Join Event'),
            ),
          ],
        ),
      ),
    );
  }
}
