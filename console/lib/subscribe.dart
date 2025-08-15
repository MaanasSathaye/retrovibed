import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/design.kit/modals.dart' as modals;

const String DEFAULT_FEED_BASE = 'https://retrovibed.example.com/subscribe/artist/';  //TODO: whatever this needs to be

// Displays a QR code for subscribing to an artist's feed.
class SubscribeQRDisplay extends StatefulWidget {
    @override
    _SubscribeQRDisplayState createState() => _SubscribeQRDisplayState();
}

class _SubscribeQRDisplayState extends State<SubscribeQRDisplay> {
    late TextEditingController artistController;
    late String qrData;

    @override
    void initState() {
        super.initState();
        artistController = TextEditingController();
        qrData = '';
    }

    void generateQR() {
        String artistId = artistController.text.trim();
        if (artistId.isNotEmpty) {
            setState(() {
                qrData = '$DEFAULT_FEED_BASE$artistId/feed';
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        return modals.Node(
            ds.Full(
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text('Enter Artist ID to Generate a Subscription QR Code', style: Theme.of(context).textTheme.headlineMedium),
                        SizedBox(height: 20),
                        TextField(
                            controller: artistController,
                            decoration: InputDecoration(labelText: 'Artist ID'),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: generateQR,
                            child: Text('Generate QR'),
                        ),
                        SizedBox(height: 40),
                        if (qrData.isNotEmpty)
                            Container(
                                color: Colors.white,  // White background for print/scan contrast
                                child: QrImageView(
                                    data: qrData,
                                    version: QrVersions.auto,
                                    size: 300,
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,  // Black QR pattern
                                ),
                            ),
                        if (qrData.isNotEmpty)
                            Text('Scan or print this QR to subscribe to the feed: $qrData'),
                    ],
                ),
            ),
        );
    }
}