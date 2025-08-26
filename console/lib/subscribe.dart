import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/design.kit/modals.dart' as modals;
import 'dart:convert';
import 'package:http/http.dart' as http;

const String DEFAULT_FEED_BASE = 'https://retrovibed.example.com/subscribe/community/';  //TODO: whatever this needs to be

class Community {
    final String id;
    final String name;

    Community({required this.id, this.name = ''});

    factory Community.fromJson(Map<String, dynamic> json) {
        return Community(
            id: json['id'] as String,
            name: json['name'] as String? ?? json['title'] ?? json['id'],
        );
    }
}

// Displays QR codes for subscribing to the user's communities.
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

    // Fetches the list of communities for the current user.
    Future<void> fetchCommunities() async {
        // TODO: Obtain baseUrl and token from context, e.g., via authn and meta.
        // For example:
        // final endpoint = meta.EndpointAuto.of(context);
        // String baseUrl = endpoint.baseUrl + '/community';
        // String token = authn.Authenticated.of(context).token;
        String baseUrl = 'http://localhost:8080/community'; // Placeholder
        String token = 'dummy_token'; // Placeholder

        try {
            final uri = Uri.parse(baseUrl);
            final request = http.Request('GET', uri);
            request.headers['Content-Type'] = 'application/json';
            request.headers['Authorization'] = 'Bearer $token';
            final searchReq = {
                'query': '',
                'offset': 0,
                'limit': 100,
            };
            request.body = json.encode(searchReq);
            final client = http.Client();
            final streamedResponse = await client.send(request);
            final response = await http.Response.fromStream(streamedResponse);

            if (response.statusCode == 200) {
                final data = json.decode(response.body) as Map<String, dynamic>;
                final items = data['items'] as List<dynamic>? ?? [];
                setState(() {
                    communities = items.map((item) => Community.fromJson(item as Map<String, dynamic>)).toList();
                    loading = false;
                });
            } else {
                setState(() {
                    errorMsg = 'Failed to load communities: ${response.statusCode}';
                    loading = false;
                });
            }
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
                                    final qrData = '$DEFAULT_FEED_BASE${community.id}/feed';
                                    return Card(
                                        child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                                children: [
                                                    Expanded(
                                                        child: Text(community.name, style: Theme.of(context).textTheme.titleMedium),
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
                                                        child: Text('Scan or print this QR to subscribe to the feed: $qrData'),
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