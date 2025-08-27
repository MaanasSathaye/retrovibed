import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/design.kit/modals.dart' as modals;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:retrovibed/httpx.dart' as httpx;
import 'package:retrovibed/community/api.dart' as community_api;
import 'package:retrovibed/authn.dart' as authn;
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
    late Widget _cause;

    void setState(VoidCallback fn) {
        if (!mounted) return;
        super.setState(fn);
    }

    void _clearCause() {
        setState(() {
            _cause = const SizedBox();
        });
    }

    @override
    void initState() {
        super.initState();
        communities = [];
        loading = true;
        _cause = const SizedBox();
        fetchCommunities(context);
    }

    // Fetches the list of communities for the current user using the community API.
    void fetchCommunities(BuildContext context) {
        final authOptions = [authn.AuthzCache.bearer(context)];
        
        community_api.search(
            options: [httpx.Accept.json, ...authOptions],
            limit: 100
        ).then((response) {
            setState(() {
                communities = response.items;
                _cause = const SizedBox();
            });
        }).catchError((cause) {
            setState(() {
                _cause = ds.Error.offline(
                    cause,
                    onTap: _clearCause,
                );
            });
        }, test: ds.ErrorTests.offline)
        .catchError((cause) {
            setState(() {
                _cause = ds.Error.connectivity(
                    cause,
                    onTap: _clearCause,
                );
            });
        }, test: ds.ErrorTests.connectivity)
        .catchError((cause) {
            setState(() {
                _cause = ds.Error.unknown(
                    cause,
                    onTap: _clearCause,
                );
            });
        })
        .whenComplete(() {
            setState(() {
                loading = false;
            });
        });
    }

    @override
    Widget build(BuildContext context) {
        return ds.Loading(
            key: ValueKey(communities.length), 
            loading: loading, 
            cause: _cause,
            modals.Node(
                ds.Full(
                    communities.isEmpty && !loading && _cause is SizedBox
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
            ),
        );
    }
}