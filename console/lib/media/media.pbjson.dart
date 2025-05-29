//
//  Generated code. Do not modify.
//  source: media.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use mediaDescriptor instead')
const Media$json = {
  '1': 'Media',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {'1': 'mimetype', '3': 3, '4': 1, '5': 9, '10': 'mimetype'},
    {'1': 'image', '3': 4, '4': 1, '5': 9, '10': 'image'},
    {'1': 'archive_id', '3': 5, '4': 1, '5': 9, '10': 'archive_id'},
    {'1': 'torrent_id', '3': 6, '4': 1, '5': 9, '10': 'torrent_id'},
    {'1': 'created_at', '3': 7, '4': 1, '5': 9, '10': 'created_at'},
    {'1': 'updated_at', '3': 8, '4': 1, '5': 9, '10': 'updated_at'},
    {'1': 'known_media_id', '3': 9, '4': 1, '5': 9, '10': 'known_media_id'},
  ],
};

/// Descriptor for `Media`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mediaDescriptor = $convert.base64Decode(
    'CgVNZWRpYRIOCgJpZBgBIAEoCVICaWQSIAoLZGVzY3JpcHRpb24YAiABKAlSC2Rlc2NyaXB0aW'
    '9uEhoKCG1pbWV0eXBlGAMgASgJUghtaW1ldHlwZRIUCgVpbWFnZRgEIAEoCVIFaW1hZ2USHgoK'
    'YXJjaGl2ZV9pZBgFIAEoCVIKYXJjaGl2ZV9pZBIeCgp0b3JyZW50X2lkGAYgASgJUgp0b3JyZW'
    '50X2lkEh4KCmNyZWF0ZWRfYXQYByABKAlSCmNyZWF0ZWRfYXQSHgoKdXBkYXRlZF9hdBgIIAEo'
    'CVIKdXBkYXRlZF9hdBImCg5rbm93bl9tZWRpYV9pZBgJIAEoCVIOa25vd25fbWVkaWFfaWQ=');

@$core.Deprecated('Use mediaSearchRequestDescriptor instead')
const MediaSearchRequest$json = {
  '1': 'MediaSearchRequest',
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

/// Descriptor for `MediaSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mediaSearchRequestDescriptor = $convert.base64Decode(
    'ChJNZWRpYVNlYXJjaFJlcXVlc3QSFAoFcXVlcnkYASABKAlSBXF1ZXJ5EhcKBm9mZnNldBiEBy'
    'ABKARSBm9mZnNldBIVCgVsaW1pdBiFByABKARSBWxpbWl0SgUIAhCEB0oGCIYHEOgH');

@$core.Deprecated('Use mediaSearchResponseDescriptor instead')
const MediaSearchResponse$json = {
  '1': 'MediaSearchResponse',
  '2': [
    {'1': 'next', '3': 1, '4': 1, '5': 11, '6': '.media.MediaSearchRequest', '10': 'next'},
    {'1': 'items', '3': 2, '4': 3, '5': 11, '6': '.media.Media', '10': 'items'},
  ],
};

/// Descriptor for `MediaSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mediaSearchResponseDescriptor = $convert.base64Decode(
    'ChNNZWRpYVNlYXJjaFJlc3BvbnNlEi0KBG5leHQYASABKAsyGS5tZWRpYS5NZWRpYVNlYXJjaF'
    'JlcXVlc3RSBG5leHQSIgoFaXRlbXMYAiADKAsyDC5tZWRpYS5NZWRpYVIFaXRlbXM=');

@$core.Deprecated('Use mediaUpdateRequestDescriptor instead')
const MediaUpdateRequest$json = {
  '1': 'MediaUpdateRequest',
  '2': [
    {'1': 'media', '3': 1, '4': 1, '5': 11, '6': '.media.Media', '10': 'media'},
  ],
};

/// Descriptor for `MediaUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mediaUpdateRequestDescriptor = $convert.base64Decode(
    'ChJNZWRpYVVwZGF0ZVJlcXVlc3QSIgoFbWVkaWEYASABKAsyDC5tZWRpYS5NZWRpYVIFbWVkaW'
    'E=');

@$core.Deprecated('Use mediaUpdateResponseDescriptor instead')
const MediaUpdateResponse$json = {
  '1': 'MediaUpdateResponse',
  '2': [
    {'1': 'media', '3': 1, '4': 1, '5': 11, '6': '.media.Media', '10': 'media'},
  ],
};

/// Descriptor for `MediaUpdateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mediaUpdateResponseDescriptor = $convert.base64Decode(
    'ChNNZWRpYVVwZGF0ZVJlc3BvbnNlEiIKBW1lZGlhGAEgASgLMgwubWVkaWEuTWVkaWFSBW1lZG'
    'lh');

@$core.Deprecated('Use mediaDeleteRequestDescriptor instead')
const MediaDeleteRequest$json = {
  '1': 'MediaDeleteRequest',
};

/// Descriptor for `MediaDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mediaDeleteRequestDescriptor = $convert.base64Decode(
    'ChJNZWRpYURlbGV0ZVJlcXVlc3Q=');

@$core.Deprecated('Use mediaDeleteResponseDescriptor instead')
const MediaDeleteResponse$json = {
  '1': 'MediaDeleteResponse',
  '2': [
    {'1': 'media', '3': 1, '4': 1, '5': 11, '6': '.media.Media', '10': 'media'},
  ],
};

/// Descriptor for `MediaDeleteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mediaDeleteResponseDescriptor = $convert.base64Decode(
    'ChNNZWRpYURlbGV0ZVJlc3BvbnNlEiIKBW1lZGlhGAEgASgLMgwubWVkaWEuTWVkaWFSBW1lZG'
    'lh');

@$core.Deprecated('Use mediaUploadResponseDescriptor instead')
const MediaUploadResponse$json = {
  '1': 'MediaUploadResponse',
  '2': [
    {'1': 'media', '3': 1, '4': 1, '5': 11, '6': '.media.Media', '10': 'media'},
  ],
};

/// Descriptor for `MediaUploadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mediaUploadResponseDescriptor = $convert.base64Decode(
    'ChNNZWRpYVVwbG9hZFJlc3BvbnNlEiIKBW1lZGlhGAEgASgLMgwubWVkaWEuTWVkaWFSBW1lZG'
    'lh');

@$core.Deprecated('Use downloadDescriptor instead')
const Download$json = {
  '1': 'Download',
  '2': [
    {'1': 'media', '3': 1, '4': 1, '5': 11, '6': '.media.Media', '10': 'media'},
    {'1': 'bytes', '3': 2, '4': 1, '5': 4, '10': 'bytes'},
    {'1': 'downloaded', '3': 3, '4': 1, '5': 4, '10': 'downloaded'},
    {'1': 'initiated_at', '3': 4, '4': 1, '5': 9, '10': 'initiated_at'},
    {'1': 'paused_at', '3': 5, '4': 1, '5': 9, '10': 'paused_at'},
    {'1': 'peers', '3': 6, '4': 1, '5': 13, '10': 'peers'},
  ],
};

/// Descriptor for `Download`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadDescriptor = $convert.base64Decode(
    'CghEb3dubG9hZBIiCgVtZWRpYRgBIAEoCzIMLm1lZGlhLk1lZGlhUgVtZWRpYRIUCgVieXRlcx'
    'gCIAEoBFIFYnl0ZXMSHgoKZG93bmxvYWRlZBgDIAEoBFIKZG93bmxvYWRlZBIiCgxpbml0aWF0'
    'ZWRfYXQYBCABKAlSDGluaXRpYXRlZF9hdBIcCglwYXVzZWRfYXQYBSABKAlSCXBhdXNlZF9hdB'
    'IUCgVwZWVycxgGIAEoDVIFcGVlcnM=');

@$core.Deprecated('Use downloadSearchRequestDescriptor instead')
const DownloadSearchRequest$json = {
  '1': 'DownloadSearchRequest',
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

/// Descriptor for `DownloadSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadSearchRequestDescriptor = $convert.base64Decode(
    'ChVEb3dubG9hZFNlYXJjaFJlcXVlc3QSFAoFcXVlcnkYASABKAlSBXF1ZXJ5EhcKBm9mZnNldB'
    'iEByABKARSBm9mZnNldBIVCgVsaW1pdBiFByABKARSBWxpbWl0SgUIAhCEB0oGCIYHEOgH');

@$core.Deprecated('Use downloadSearchResponseDescriptor instead')
const DownloadSearchResponse$json = {
  '1': 'DownloadSearchResponse',
  '2': [
    {'1': 'next', '3': 1, '4': 1, '5': 11, '6': '.media.DownloadSearchRequest', '10': 'next'},
    {'1': 'items', '3': 2, '4': 3, '5': 11, '6': '.media.Download', '10': 'items'},
  ],
};

/// Descriptor for `DownloadSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadSearchResponseDescriptor = $convert.base64Decode(
    'ChZEb3dubG9hZFNlYXJjaFJlc3BvbnNlEjAKBG5leHQYASABKAsyHC5tZWRpYS5Eb3dubG9hZF'
    'NlYXJjaFJlcXVlc3RSBG5leHQSJQoFaXRlbXMYAiADKAsyDy5tZWRpYS5Eb3dubG9hZFIFaXRl'
    'bXM=');

@$core.Deprecated('Use downloadMetadataRequestDescriptor instead')
const DownloadMetadataRequest$json = {
  '1': 'DownloadMetadataRequest',
};

/// Descriptor for `DownloadMetadataRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadMetadataRequestDescriptor = $convert.base64Decode(
    'ChdEb3dubG9hZE1ldGFkYXRhUmVxdWVzdA==');

@$core.Deprecated('Use downloadMetadataResponseDescriptor instead')
const DownloadMetadataResponse$json = {
  '1': 'DownloadMetadataResponse',
  '2': [
    {'1': 'download', '3': 1, '4': 1, '5': 11, '6': '.media.Download', '10': 'download'},
  ],
};

/// Descriptor for `DownloadMetadataResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadMetadataResponseDescriptor = $convert.base64Decode(
    'ChhEb3dubG9hZE1ldGFkYXRhUmVzcG9uc2USKwoIZG93bmxvYWQYASABKAsyDy5tZWRpYS5Eb3'
    'dubG9hZFIIZG93bmxvYWQ=');

@$core.Deprecated('Use downloadBeginRequestDescriptor instead')
const DownloadBeginRequest$json = {
  '1': 'DownloadBeginRequest',
};

/// Descriptor for `DownloadBeginRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadBeginRequestDescriptor = $convert.base64Decode(
    'ChREb3dubG9hZEJlZ2luUmVxdWVzdA==');

@$core.Deprecated('Use downloadBeginResponseDescriptor instead')
const DownloadBeginResponse$json = {
  '1': 'DownloadBeginResponse',
  '2': [
    {'1': 'download', '3': 1, '4': 1, '5': 11, '6': '.media.Download', '10': 'download'},
  ],
};

/// Descriptor for `DownloadBeginResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadBeginResponseDescriptor = $convert.base64Decode(
    'ChVEb3dubG9hZEJlZ2luUmVzcG9uc2USKwoIZG93bmxvYWQYASABKAsyDy5tZWRpYS5Eb3dubG'
    '9hZFIIZG93bmxvYWQ=');

@$core.Deprecated('Use downloadPauseRequestDescriptor instead')
const DownloadPauseRequest$json = {
  '1': 'DownloadPauseRequest',
};

/// Descriptor for `DownloadPauseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadPauseRequestDescriptor = $convert.base64Decode(
    'ChREb3dubG9hZFBhdXNlUmVxdWVzdA==');

@$core.Deprecated('Use downloadPauseResponseDescriptor instead')
const DownloadPauseResponse$json = {
  '1': 'DownloadPauseResponse',
  '2': [
    {'1': 'download', '3': 1, '4': 1, '5': 11, '6': '.media.Download', '10': 'download'},
  ],
};

/// Descriptor for `DownloadPauseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadPauseResponseDescriptor = $convert.base64Decode(
    'ChVEb3dubG9hZFBhdXNlUmVzcG9uc2USKwoIZG93bmxvYWQYASABKAsyDy5tZWRpYS5Eb3dubG'
    '9hZFIIZG93bmxvYWQ=');

