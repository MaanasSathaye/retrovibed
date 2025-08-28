// This is a generated file - do not edit.
//
// Generated from community.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use communityDescriptor instead')
const Community$json = {
  '1': 'Community',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'account_id', '3': 2, '4': 1, '5': 9, '10': 'account_id'},
    {'1': 'created_at', '3': 4, '4': 1, '5': 9, '10': 'created_at'},
    {'1': 'updated_at', '3': 5, '4': 1, '5': 9, '10': 'updated_at'},
    {'1': 'mimetype', '3': 6, '4': 1, '5': 9, '10': 'mimetype'},
    {'1': 'domain', '3': 7, '4': 1, '5': 9, '10': 'domain'},
    {'1': 'description', '3': 8, '4': 1, '5': 9, '10': 'description'},
    {'1': 'entropy', '3': 9, '4': 1, '5': 9, '10': 'entropy'},
    {'1': 'bytes', '3': 10, '4': 1, '5': 4, '10': 'bytes'},
  ],
  '9': [
    {'1': 20, '2': 1000},
  ],
};

/// Descriptor for `Community`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List communityDescriptor = $convert.base64Decode(
    'CglDb21tdW5pdHkSDgoCaWQYASABKAlSAmlkEh4KCmFjY291bnRfaWQYAiABKAlSCmFjY291bn'
    'RfaWQSHgoKY3JlYXRlZF9hdBgEIAEoCVIKY3JlYXRlZF9hdBIeCgp1cGRhdGVkX2F0GAUgASgJ'
    'Ugp1cGRhdGVkX2F0EhoKCG1pbWV0eXBlGAYgASgJUghtaW1ldHlwZRIWCgZkb21haW4YByABKA'
    'lSBmRvbWFpbhIgCgtkZXNjcmlwdGlvbhgIIAEoCVILZGVzY3JpcHRpb24SGAoHZW50cm9weRgJ'
    'IAEoCVIHZW50cm9weRIUCgVieXRlcxgKIAEoBFIFYnl0ZXNKBQgUEOgH');

@$core.Deprecated('Use communitySearchRequestDescriptor instead')
const CommunitySearchRequest$json = {
  '1': 'CommunitySearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'offset', '3': 2, '4': 1, '5': 4, '10': 'offset'},
    {'1': 'limit', '3': 3, '4': 1, '5': 4, '10': 'limit'},
  ],
  '9': [
    {'1': 4, '2': 1000},
  ],
};

/// Descriptor for `CommunitySearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List communitySearchRequestDescriptor =
    $convert.base64Decode(
        'ChZDb21tdW5pdHlTZWFyY2hSZXF1ZXN0EhQKBXF1ZXJ5GAEgASgJUgVxdWVyeRIWCgZvZmZzZX'
        'QYAiABKARSBm9mZnNldBIUCgVsaW1pdBgDIAEoBFIFbGltaXRKBQgEEOgH');

@$core.Deprecated('Use communitySearchResponseDescriptor instead')
const CommunitySearchResponse$json = {
  '1': 'CommunitySearchResponse',
  '2': [
    {
      '1': 'next',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.retrovibed.community.CommunitySearchRequest',
      '10': 'next'
    },
    {
      '1': 'items',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.retrovibed.community.Community',
      '10': 'items'
    },
  ],
};

/// Descriptor for `CommunitySearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List communitySearchResponseDescriptor = $convert.base64Decode(
    'ChdDb21tdW5pdHlTZWFyY2hSZXNwb25zZRJACgRuZXh0GAEgASgLMiwucmV0cm92aWJlZC5jb2'
    '1tdW5pdHkuQ29tbXVuaXR5U2VhcmNoUmVxdWVzdFIEbmV4dBI1CgVpdGVtcxgCIAMoCzIfLnJl'
    'dHJvdmliZWQuY29tbXVuaXR5LkNvbW11bml0eVIFaXRlbXM=');

@$core.Deprecated('Use communityCreateRequestDescriptor instead')
const CommunityCreateRequest$json = {
  '1': 'CommunityCreateRequest',
  '2': [
    {
      '1': 'community',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.retrovibed.community.Community',
      '10': 'community'
    },
  ],
};

/// Descriptor for `CommunityCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List communityCreateRequestDescriptor =
    $convert.base64Decode(
        'ChZDb21tdW5pdHlDcmVhdGVSZXF1ZXN0Ej0KCWNvbW11bml0eRgBIAEoCzIfLnJldHJvdmliZW'
        'QuY29tbXVuaXR5LkNvbW11bml0eVIJY29tbXVuaXR5');

@$core.Deprecated('Use communityCreateResponseDescriptor instead')
const CommunityCreateResponse$json = {
  '1': 'CommunityCreateResponse',
  '2': [
    {
      '1': 'community',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.retrovibed.community.Community',
      '10': 'community'
    },
  ],
};

/// Descriptor for `CommunityCreateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List communityCreateResponseDescriptor =
    $convert.base64Decode(
        'ChdDb21tdW5pdHlDcmVhdGVSZXNwb25zZRI9Cgljb21tdW5pdHkYASABKAsyHy5yZXRyb3ZpYm'
        'VkLmNvbW11bml0eS5Db21tdW5pdHlSCWNvbW11bml0eQ==');

@$core.Deprecated('Use communityFindRequestDescriptor instead')
const CommunityFindRequest$json = {
  '1': 'CommunityFindRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `CommunityFindRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List communityFindRequestDescriptor = $convert
    .base64Decode('ChRDb21tdW5pdHlGaW5kUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use communityFindResponseDescriptor instead')
const CommunityFindResponse$json = {
  '1': 'CommunityFindResponse',
  '2': [
    {
      '1': 'community',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.retrovibed.community.Community',
      '10': 'community'
    },
  ],
};

/// Descriptor for `CommunityFindResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List communityFindResponseDescriptor = $convert.base64Decode(
    'ChVDb21tdW5pdHlGaW5kUmVzcG9uc2USPQoJY29tbXVuaXR5GAEgASgLMh8ucmV0cm92aWJlZC'
    '5jb21tdW5pdHkuQ29tbXVuaXR5Ugljb21tdW5pdHk=');

@$core.Deprecated('Use communityUploadRequestDescriptor instead')
const CommunityUploadRequest$json = {
  '1': 'CommunityUploadRequest',
  '2': [
    {
      '1': 'community',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.retrovibed.community.Community',
      '10': 'community'
    },
  ],
};

/// Descriptor for `CommunityUploadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List communityUploadRequestDescriptor =
    $convert.base64Decode(
        'ChZDb21tdW5pdHlVcGxvYWRSZXF1ZXN0Ej0KCWNvbW11bml0eRgBIAEoCzIfLnJldHJvdmliZW'
        'QuY29tbXVuaXR5LkNvbW11bml0eVIJY29tbXVuaXR5');

@$core.Deprecated('Use communityUploadResponseDescriptor instead')
const CommunityUploadResponse$json = {
  '1': 'CommunityUploadResponse',
  '2': [
    {
      '1': 'community',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.retrovibed.community.Community',
      '10': 'community'
    },
  ],
};

/// Descriptor for `CommunityUploadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List communityUploadResponseDescriptor =
    $convert.base64Decode(
        'ChdDb21tdW5pdHlVcGxvYWRSZXNwb25zZRI9Cgljb21tdW5pdHkYASABKAsyHy5yZXRyb3ZpYm'
        'VkLmNvbW11bml0eS5Db21tdW5pdHlSCWNvbW11bml0eQ==');
