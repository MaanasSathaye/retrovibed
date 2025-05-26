//
//  Generated code. Do not modify.
//  source: media.known.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use knownDescriptor instead')
const Known$json = {
  '1': 'Known',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {'1': 'mimetype', '3': 3, '4': 1, '5': 9, '10': 'mimetype'},
    {'1': 'image', '3': 4, '4': 1, '5': 9, '10': 'image'},
    {'1': 'archive_id', '3': 5, '4': 1, '5': 9, '10': 'archive_id'},
    {'1': 'torrent_id', '3': 6, '4': 1, '5': 9, '10': 'torrent_id'},
    {'1': 'created_at', '3': 7, '4': 1, '5': 9, '10': 'created_at'},
    {'1': 'updated_at', '3': 8, '4': 1, '5': 9, '10': 'updated_at'},
    {'1': 'metadata', '3': 9, '4': 1, '5': 9, '10': 'metadata'},
  ],
};

/// Descriptor for `Known`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List knownDescriptor = $convert.base64Decode(
    'CgVLbm93bhIOCgJpZBgBIAEoCVICaWQSIAoLZGVzY3JpcHRpb24YAiABKAlSC2Rlc2NyaXB0aW'
    '9uEhoKCG1pbWV0eXBlGAMgASgJUghtaW1ldHlwZRIUCgVpbWFnZRgEIAEoCVIFaW1hZ2USHgoK'
    'YXJjaGl2ZV9pZBgFIAEoCVIKYXJjaGl2ZV9pZBIeCgp0b3JyZW50X2lkGAYgASgJUgp0b3JyZW'
    '50X2lkEh4KCmNyZWF0ZWRfYXQYByABKAlSCmNyZWF0ZWRfYXQSHgoKdXBkYXRlZF9hdBgIIAEo'
    'CVIKdXBkYXRlZF9hdBIaCghtZXRhZGF0YRgJIAEoCVIIbWV0YWRhdGE=');

@$core.Deprecated('Use knownSearchRequestDescriptor instead')
const KnownSearchRequest$json = {
  '1': 'KnownSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'offset', '3': 900, '4': 1, '5': 4, '10': 'offset'},
    {'1': 'limit', '3': 901, '4': 1, '5': 4, '10': 'limit'},
  ],
  '9': [
    {'1': 2, '2': 900},
    {'1': 902, '2': 1000},
  ],
};

/// Descriptor for `KnownSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List knownSearchRequestDescriptor = $convert.base64Decode(
    'ChJLbm93blNlYXJjaFJlcXVlc3QSFAoFcXVlcnkYASABKAlSBXF1ZXJ5EhcKBm9mZnNldBiEBy'
    'ABKARSBm9mZnNldBIVCgVsaW1pdBiFByABKARSBWxpbWl0SgUIAhCEB0oGCIYHEOgH');

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

