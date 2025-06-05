//
//  Generated code. Do not modify.
//  source: meta.billing.proto
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

@$core.Deprecated('Use billingDescriptor instead')
const Billing$json = {
  '1': 'Billing',
  '2': [
    {'1': 'customer_id', '3': 1, '4': 1, '5': 9, '10': 'customer_id'},
    {'1': 'plan_id', '3': 2, '4': 1, '5': 9, '10': 'plan_id'},
    {'1': 'subscription_id', '3': 3, '4': 1, '5': 9, '10': 'subscription_id'},
    {'1': 'subscription_ended_at', '3': 4, '4': 1, '5': 9, '10': 'subscription_ended_at'},
  ],
};

/// Descriptor for `Billing`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List billingDescriptor = $convert.base64Decode(
    'CgdCaWxsaW5nEiAKC2N1c3RvbWVyX2lkGAEgASgJUgtjdXN0b21lcl9pZBIYCgdwbGFuX2lkGA'
    'IgASgJUgdwbGFuX2lkEigKD3N1YnNjcmlwdGlvbl9pZBgDIAEoCVIPc3Vic2NyaXB0aW9uX2lk'
    'EjQKFXN1YnNjcmlwdGlvbl9lbmRlZF9hdBgEIAEoCVIVc3Vic2NyaXB0aW9uX2VuZGVkX2F0');

@$core.Deprecated('Use billingCreateRequestDescriptor instead')
const BillingCreateRequest$json = {
  '1': 'BillingCreateRequest',
};

/// Descriptor for `BillingCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List billingCreateRequestDescriptor = $convert.base64Decode(
    'ChRCaWxsaW5nQ3JlYXRlUmVxdWVzdA==');

@$core.Deprecated('Use billingCreateResponseDescriptor instead')
const BillingCreateResponse$json = {
  '1': 'BillingCreateResponse',
  '2': [
    {'1': 'billing', '3': 1, '4': 1, '5': 11, '6': '.meta.Billing', '10': 'billing'},
  ],
};

/// Descriptor for `BillingCreateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List billingCreateResponseDescriptor = $convert.base64Decode(
    'ChVCaWxsaW5nQ3JlYXRlUmVzcG9uc2USJwoHYmlsbGluZxgBIAEoCzINLm1ldGEuQmlsbGluZ1'
    'IHYmlsbGluZw==');

@$core.Deprecated('Use billingLookupRequestDescriptor instead')
const BillingLookupRequest$json = {
  '1': 'BillingLookupRequest',
};

/// Descriptor for `BillingLookupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List billingLookupRequestDescriptor = $convert.base64Decode(
    'ChRCaWxsaW5nTG9va3VwUmVxdWVzdA==');

@$core.Deprecated('Use billingLookupResponseDescriptor instead')
const BillingLookupResponse$json = {
  '1': 'BillingLookupResponse',
  '2': [
    {'1': 'billing', '3': 1, '4': 1, '5': 11, '6': '.meta.Billing', '10': 'billing'},
  ],
};

/// Descriptor for `BillingLookupResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List billingLookupResponseDescriptor = $convert.base64Decode(
    'ChVCaWxsaW5nTG9va3VwUmVzcG9uc2USJwoHYmlsbGluZxgBIAEoCzINLm1ldGEuQmlsbGluZ1'
    'IHYmlsbGluZw==');

@$core.Deprecated('Use billingSubscribeRequestDescriptor instead')
const BillingSubscribeRequest$json = {
  '1': 'BillingSubscribeRequest',
  '2': [
    {'1': 'plan', '3': 1, '4': 1, '5': 9, '10': 'plan'},
  ],
};

/// Descriptor for `BillingSubscribeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List billingSubscribeRequestDescriptor = $convert.base64Decode(
    'ChdCaWxsaW5nU3Vic2NyaWJlUmVxdWVzdBISCgRwbGFuGAEgASgJUgRwbGFu');

@$core.Deprecated('Use billingSubscribeResponseDescriptor instead')
const BillingSubscribeResponse$json = {
  '1': 'BillingSubscribeResponse',
  '2': [
    {'1': 'billing', '3': 1, '4': 1, '5': 11, '6': '.meta.Billing', '10': 'billing'},
  ],
};

/// Descriptor for `BillingSubscribeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List billingSubscribeResponseDescriptor = $convert.base64Decode(
    'ChhCaWxsaW5nU3Vic2NyaWJlUmVzcG9uc2USJwoHYmlsbGluZxgBIAEoCzINLm1ldGEuQmlsbG'
    'luZ1IHYmlsbGluZw==');

@$core.Deprecated('Use billingSessionRequestDescriptor instead')
const BillingSessionRequest$json = {
  '1': 'BillingSessionRequest',
  '2': [
    {'1': 'plan', '3': 1, '4': 1, '5': 9, '10': 'plan'},
  ],
};

/// Descriptor for `BillingSessionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List billingSessionRequestDescriptor = $convert.base64Decode(
    'ChVCaWxsaW5nU2Vzc2lvblJlcXVlc3QSEgoEcGxhbhgBIAEoCVIEcGxhbg==');

@$core.Deprecated('Use billingSessionResponseDescriptor instead')
const BillingSessionResponse$json = {
  '1': 'BillingSessionResponse',
  '2': [
    {'1': 'redirect', '3': 1, '4': 1, '5': 9, '10': 'redirect'},
  ],
};

/// Descriptor for `BillingSessionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List billingSessionResponseDescriptor = $convert.base64Decode(
    'ChZCaWxsaW5nU2Vzc2lvblJlc3BvbnNlEhoKCHJlZGlyZWN0GAEgASgJUghyZWRpcmVjdA==');

