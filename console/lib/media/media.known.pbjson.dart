//
//  Generated code. Do not modify.
//  source: media.known.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use knownDescriptor instead')
const Known$json = {
  '1': 'Known',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'rating', '3': 2, '4': 1, '5': 2, '10': 'rating'},
    {'1': 'adult', '3': 3, '4': 1, '5': 8, '10': 'adult'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'summary', '3': 5, '4': 1, '5': 9, '10': 'summary'},
    {'1': 'image', '3': 6, '4': 1, '5': 9, '10': 'image'},
  ],
};

/// Descriptor for `Known`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List knownDescriptor = $convert.base64Decode(
    'CgVLbm93bhIOCgJpZBgBIAEoCVICaWQSFgoGcmF0aW5nGAIgASgCUgZyYXRpbmcSFAoFYWR1bH'
    'QYAyABKAhSBWFkdWx0EiAKC2Rlc2NyaXB0aW9uGAQgASgJUgtkZXNjcmlwdGlvbhIYCgdzdW1t'
    'YXJ5GAUgASgJUgdzdW1tYXJ5EhQKBWltYWdlGAYgASgJUgVpbWFnZQ==');

@$core.Deprecated('Use knownSearchRequestDescriptor instead')
const KnownSearchRequest$json = {
  '1': 'KnownSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'adult', '3': 2, '4': 1, '5': 8, '10': 'adult'},
    {'1': 'offset', '3': 900, '4': 1, '5': 4, '10': 'offset'},
    {'1': 'limit', '3': 901, '4': 1, '5': 4, '10': 'limit'},
  ],
  '9': [
    {'1': 3, '2': 900},
    {'1': 902, '2': 1000},
  ],
};

/// Descriptor for `KnownSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List knownSearchRequestDescriptor = $convert.base64Decode(
    'ChJLbm93blNlYXJjaFJlcXVlc3QSFAoFcXVlcnkYASABKAlSBXF1ZXJ5EhQKBWFkdWx0GAIgAS'
    'gIUgVhZHVsdBIXCgZvZmZzZXQYhAcgASgEUgZvZmZzZXQSFQoFbGltaXQYhQcgASgEUgVsaW1p'
    'dEoFCAMQhAdKBgiGBxDoBw==');

@$core.Deprecated('Use knownSearchResponseDescriptor instead')
const KnownSearchResponse$json = {
  '1': 'KnownSearchResponse',
  '2': [
    {'1': 'next', '3': 1, '4': 1, '5': 11, '6': '.media.KnownSearchRequest', '10': 'next'},
    {'1': 'items', '3': 2, '4': 3, '5': 11, '6': '.media.Known', '10': 'items'},
  ],
};

/// Descriptor for `KnownSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List knownSearchResponseDescriptor = $convert.base64Decode(
    'ChNLbm93blNlYXJjaFJlc3BvbnNlEi0KBG5leHQYASABKAsyGS5tZWRpYS5Lbm93blNlYXJjaF'
    'JlcXVlc3RSBG5leHQSIgoFaXRlbXMYAiADKAsyDC5tZWRpYS5Lbm93blIFaXRlbXM=');

@$core.Deprecated('Use knownMatchRequestDescriptor instead')
const KnownMatchRequest$json = {
  '1': 'KnownMatchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
  ],
};

/// Descriptor for `KnownMatchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List knownMatchRequestDescriptor = $convert.base64Decode(
    'ChFLbm93bk1hdGNoUmVxdWVzdBIUCgVxdWVyeRgBIAEoCVIFcXVlcnk=');

@$core.Deprecated('Use knownLookupRequestDescriptor instead')
const KnownLookupRequest$json = {
  '1': 'KnownLookupRequest',
};

/// Descriptor for `KnownLookupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List knownLookupRequestDescriptor = $convert.base64Decode(
    'ChJLbm93bkxvb2t1cFJlcXVlc3Q=');

@$core.Deprecated('Use knownLookupResponseDescriptor instead')
const KnownLookupResponse$json = {
  '1': 'KnownLookupResponse',
  '2': [
    {'1': 'known', '3': 1, '4': 1, '5': 11, '6': '.media.Known', '10': 'known'},
  ],
};

/// Descriptor for `KnownLookupResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List knownLookupResponseDescriptor = $convert.base64Decode(
    'ChNLbm93bkxvb2t1cFJlc3BvbnNlEiIKBWtub3duGAEgASgLMgwubWVkaWEuS25vd25SBWtub3'
    'du');

