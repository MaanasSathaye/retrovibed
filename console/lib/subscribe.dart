import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/design.kit/modals.dart' as modals;

const String DEFAULT_FEED_BASE = 'https://retrovibed.example.com/subscribe/artist/';  // Placeholder; fetch dynamic base from backend or use external IP.

// Displays a list of available artist feeds with inline QR codes for subscription.
class SubscribeQRDisplay extends StatefulWidget {
    @override
    _SubscribeQRDisplayState createState() => _SubscribeQRDisplayState();
}

class _SubscribeQRDisplayState extends State<SubscribeQRDisplay> {
    late List<String> artists;  // Placeholder for fetched artists/communities

    @override
    void initState() {
        super.initState();
        artists = ['artist1', 'artist2', 'artist3'];
        // TODO: Implement fetchCommunities() async { http.get('$baseUrl/community/list') } and update artists.
    }

    @override
    Widget build(BuildContext context) {
        return modals.Node(
            ds.Full(
                Column(
                    children: [
                        Text('Available Artist Feeds for Subscription', style: Theme.of(context).textTheme.headlineMedium),
                        SizedBox(height: 20),
                        Expanded(
                            child: ListView.builder(
                                itemCount: artists.length,
                                itemBuilder: (context, index) {
                                    String artist = artists[index];
                                    String qrData = '$DEFAULT_FEED_BASE$artist/feed';
                                    return Card(
                                        child: ListTile(
                                            title: Text(artist),
                                            trailing: Container(
                                                color: Colors.white,
                                                width: 100,
                                                height: 100,
                                                child: QrImageView(
                                                    data: qrData,
                                                    version: QrVersions.auto,
                                                    backgroundColor: Colors.white,
                                                    foregroundColor: Colors.black,
                                                ),
                                            ),
                                            subtitle: Text('Scan or print QR: $qrData'),
                                        ),
                                    );
                                },
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}