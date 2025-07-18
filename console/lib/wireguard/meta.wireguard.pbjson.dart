// This is a generated file - do not edit.
//
// Generated from meta.wireguard.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use wireguardDescriptor instead')
const Wireguard$json = {
  '1': 'Wireguard',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `Wireguard`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wireguardDescriptor =
    $convert.base64Decode('CglXaXJlZ3VhcmQSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use wireguardSearchRequestDescriptor instead')
const WireguardSearchRequest$json = {
  '1': 'WireguardSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'offset', '3': 2, '4': 1, '5': 4, '10': 'offset'},
    {'1': 'limit', '3': 3, '4': 1, '5': 4, '10': 'limit'},
    {'1': 'status', '3': 4, '4': 1, '5': 13, '10': 'status'},
  ],
};

/// Descriptor for `WireguardSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wireguardSearchRequestDescriptor = $convert.base64Decode(
    'ChZXaXJlZ3VhcmRTZWFyY2hSZXF1ZXN0EhQKBXF1ZXJ5GAEgASgJUgVxdWVyeRIWCgZvZmZzZX'
    'QYAiABKARSBm9mZnNldBIUCgVsaW1pdBgDIAEoBFIFbGltaXQSFgoGc3RhdHVzGAQgASgNUgZz'
    'dGF0dXM=');

@$core.Deprecated('Use wireguardSearchResponseDescriptor instead')
const WireguardSearchResponse$json = {
  '1': 'WireguardSearchResponse',
  '2': [
    {
      '1': 'next',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.meta.WireguardSearchRequest',
      '10': 'next'
    },
    {
      '1': 'items',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.meta.Wireguard',
      '10': 'items'
    },
  ],
};

/// Descriptor for `WireguardSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wireguardSearchResponseDescriptor = $convert.base64Decode(
    'ChdXaXJlZ3VhcmRTZWFyY2hSZXNwb25zZRIwCgRuZXh0GAEgASgLMhwubWV0YS5XaXJlZ3Vhcm'
    'RTZWFyY2hSZXF1ZXN0UgRuZXh0EiUKBWl0ZW1zGAIgAygLMg8ubWV0YS5XaXJlZ3VhcmRSBWl0'
    'ZW1z');

@$core.Deprecated('Use wireguardTouchRequestDescriptor instead')
const WireguardTouchRequest$json = {
  '1': 'WireguardTouchRequest',
};

/// Descriptor for `WireguardTouchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wireguardTouchRequestDescriptor =
    $convert.base64Decode('ChVXaXJlZ3VhcmRUb3VjaFJlcXVlc3Q=');

@$core.Deprecated('Use wireguardTouchResponseDescriptor instead')
const WireguardTouchResponse$json = {
  '1': 'WireguardTouchResponse',
};

/// Descriptor for `WireguardTouchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wireguardTouchResponseDescriptor =
    $convert.base64Decode('ChZXaXJlZ3VhcmRUb3VjaFJlc3BvbnNl');

@$core.Deprecated('Use wireguardUploadRequestDescriptor instead')
const WireguardUploadRequest$json = {
  '1': 'WireguardUploadRequest',
};

/// Descriptor for `WireguardUploadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wireguardUploadRequestDescriptor =
    $convert.base64Decode('ChZXaXJlZ3VhcmRVcGxvYWRSZXF1ZXN0');

@$core.Deprecated('Use wireguardUploadResponseDescriptor instead')
const WireguardUploadResponse$json = {
  '1': 'WireguardUploadResponse',
  '2': [
    {
      '1': 'Wireguard',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.meta.Wireguard',
      '10': 'wireguard'
    },
  ],
};

/// Descriptor for `WireguardUploadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wireguardUploadResponseDescriptor =
    $convert.base64Decode(
        'ChdXaXJlZ3VhcmRVcGxvYWRSZXNwb25zZRItCglXaXJlZ3VhcmQYASABKAsyDy5tZXRhLldpcm'
        'VndWFyZFIJd2lyZWd1YXJk');

@$core.Deprecated('Use wireguardCurrentRequestDescriptor instead')
const WireguardCurrentRequest$json = {
  '1': 'WireguardCurrentRequest',
};

/// Descriptor for `WireguardCurrentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wireguardCurrentRequestDescriptor =
    $convert.base64Decode('ChdXaXJlZ3VhcmRDdXJyZW50UmVxdWVzdA==');

@$core.Deprecated('Use wireguardCurrentResponseDescriptor instead')
const WireguardCurrentResponse$json = {
  '1': 'WireguardCurrentResponse',
  '2': [
    {
      '1': 'Wireguard',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.meta.Wireguard',
      '10': 'wireguard'
    },
  ],
};

/// Descriptor for `WireguardCurrentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wireguardCurrentResponseDescriptor =
    $convert.base64Decode(
        'ChhXaXJlZ3VhcmRDdXJyZW50UmVzcG9uc2USLQoJV2lyZWd1YXJkGAEgASgLMg8ubWV0YS5XaX'
        'JlZ3VhcmRSCXdpcmVndWFyZA==');

@$core.Deprecated('Use wireguardDeleteRequestDescriptor instead')
const WireguardDeleteRequest$json = {
  '1': 'WireguardDeleteRequest',
};

/// Descriptor for `WireguardDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wireguardDeleteRequestDescriptor =
    $convert.base64Decode('ChZXaXJlZ3VhcmREZWxldGVSZXF1ZXN0');

@$core.Deprecated('Use wireguardDeleteResponseDescriptor instead')
const WireguardDeleteResponse$json = {
  '1': 'WireguardDeleteResponse',
  '2': [
    {
      '1': 'Wireguard',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.meta.Wireguard',
      '10': 'wireguard'
    },
  ],
};

/// Descriptor for `WireguardDeleteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wireguardDeleteResponseDescriptor =
    $convert.base64Decode(
        'ChdXaXJlZ3VhcmREZWxldGVSZXNwb25zZRItCglXaXJlZ3VhcmQYASABKAsyDy5tZXRhLldpcm'
        'VndWFyZFIJd2lyZWd1YXJk');
