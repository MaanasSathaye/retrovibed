import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/design.kit/modals.dart' as modals;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:retrovibed/httpx.dart' as httpx;
import 'package:retrovibed/community/api.dart' as community_api;
import 'package:retrovibed/community/community.pb.dart';

// Displays QR codes for subscribing to the user's communities.
// Each QR code encodes the full community information directly.
class SubscribeQRDisplay extends StatefulWidget {
    @override
    _SubscribeQRDisplayState createState() => _SubscribeQRDisplayState();
}

class _SubscribeQRDisplayState extends State<SubscribeQRDisplay> {
    late List<Community> communities;
    late bool loading;
    late String errorMsg;

    @override
    void initState() {
        super.initState();
        communities = [];
        loading = true;
        errorMsg = '';
        fetchCommunities();
    }

    // Fetches the list of communities for the current user using the community API.
    Future<void> fetchCommunities() async {
        try {
            final response = await community_api.search(
                options: [httpx.Accept.json],
                limit: 100
            );
            
            setState(() {
                communities = response.items;
                loading = false;
            });
        } catch (e) {
            setState(() {
                errorMsg = e.toString();
                loading = false;
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        return modals.Node(
            ds.Full(
                loading
                    ? Center(child: CircularProgressIndicator())
                    : errorMsg.isNotEmpty
                        ? Center(child: Text(errorMsg))
                        : communities.isEmpty
                            ? Center(child: Text('No communities found'))
                            : ListView.builder(
                                itemCount: communities.length,
                                itemBuilder: (context, index) {
                                    final community = communities[index];
                                    // Encode the full community information as JSON in the QR code
                                    final qrData = jsonEncode(community.toProto3Json());
                                    return Card(
                                        child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                                children: [
                                                    Expanded(
                                                        child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                                Text(
                                                                    community.domain, 
                                                                    style: Theme.of(context).textTheme.titleMedium
                                                                ),
                                                                if (community.description.isNotEmpty)
                                                                    Text(
                                                                        community.description,
                                                                        style: Theme.of(context).textTheme.bodySmall
                                                                    ),
                                                            ],
                                                        ),
                                                    ),
                                                    Container(
                                                        color: Colors.white,
                                                        child: QrImageView(
                                                            data: qrData,
                                                            version: QrVersions.auto,
                                                            size: 100,
                                                            backgroundColor: Colors.white,
                                                            foregroundColor: Colors.black,
                                                        ),
                                                    ),
                                                    SizedBox(width: 16),
                                                    Expanded(
                                                        child: Text(
                                                            'Scan this QR code to subscribe to the ${community.domain} community feed',
                                                            style: Theme.of(context).textTheme.bodySmall
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                    );
                                },
                            ),
            ),
        );
    }
}