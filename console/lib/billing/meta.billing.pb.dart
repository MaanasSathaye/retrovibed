// This is a generated file - do not edit.
//
// Generated from meta.billing.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Billing extends $pb.GeneratedMessage {
  factory Billing({
    $core.String? customerId,
    $core.String? planId,
    $core.String? subscriptionId,
    $core.String? subscriptionEndedAt,
  }) {
    final result = create();
    if (customerId != null) result.customerId = customerId;
    if (planId != null) result.planId = planId;
    if (subscriptionId != null) result.subscriptionId = subscriptionId;
    if (subscriptionEndedAt != null) result.subscriptionEndedAt = subscriptionEndedAt;
    return result;
  }

  Billing._();

  factory Billing.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory Billing.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Billing', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'customer_id')
    ..aOS(2, _omitFieldNames ? '' : 'plan_id')
    ..aOS(3, _omitFieldNames ? '' : 'subscription_id')
    ..aOS(4, _omitFieldNames ? '' : 'subscription_ended_at')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Billing clone() => Billing()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Billing copyWith(void Function(Billing) updates) => super.copyWith((message) => updates(message as Billing)) as Billing;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Billing create() => Billing._();
  @$core.override
  Billing createEmptyInstance() => create();
  static $pb.PbList<Billing> createRepeated() => $pb.PbList<Billing>();
  @$core.pragma('dart2js:noInline')
  static Billing getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Billing>(create);
  static Billing? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get customerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set customerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCustomerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCustomerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get planId => $_getSZ(1);
  @$pb.TagNumber(2)
  set planId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPlanId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPlanId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get subscriptionId => $_getSZ(2);
  @$pb.TagNumber(3)
  set subscriptionId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSubscriptionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSubscriptionId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get subscriptionEndedAt => $_getSZ(3);
  @$pb.TagNumber(4)
  set subscriptionEndedAt($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSubscriptionEndedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearSubscriptionEndedAt() => $_clearField(4);
}

class BillingCreateRequest extends $pb.GeneratedMessage {
  factory BillingCreateRequest() => create();

  BillingCreateRequest._();

  factory BillingCreateRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory BillingCreateRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BillingCreateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BillingCreateRequest clone() => BillingCreateRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BillingCreateRequest copyWith(void Function(BillingCreateRequest) updates) => super.copyWith((message) => updates(message as BillingCreateRequest)) as BillingCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BillingCreateRequest create() => BillingCreateRequest._();
  @$core.override
  BillingCreateRequest createEmptyInstance() => create();
  static $pb.PbList<BillingCreateRequest> createRepeated() => $pb.PbList<BillingCreateRequest>();
  @$core.pragma('dart2js:noInline')
  static BillingCreateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BillingCreateRequest>(create);
  static BillingCreateRequest? _defaultInstance;
}

class BillingCreateResponse extends $pb.GeneratedMessage {
  factory BillingCreateResponse({
    Billing? billing,
  }) {
    final result = create();
    if (billing != null) result.billing = billing;
    return result;
  }

  BillingCreateResponse._();

  factory BillingCreateResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory BillingCreateResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BillingCreateResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..aOM<Billing>(1, _omitFieldNames ? '' : 'billing', subBuilder: Billing.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BillingCreateResponse clone() => BillingCreateResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BillingCreateResponse copyWith(void Function(BillingCreateResponse) updates) => super.copyWith((message) => updates(message as BillingCreateResponse)) as BillingCreateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BillingCreateResponse create() => BillingCreateResponse._();
  @$core.override
  BillingCreateResponse createEmptyInstance() => create();
  static $pb.PbList<BillingCreateResponse> createRepeated() => $pb.PbList<BillingCreateResponse>();
  @$core.pragma('dart2js:noInline')
  static BillingCreateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BillingCreateResponse>(create);
  static BillingCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Billing get billing => $_getN(0);
  @$pb.TagNumber(1)
  set billing(Billing value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBilling() => $_has(0);
  @$pb.TagNumber(1)
  void clearBilling() => $_clearField(1);
  @$pb.TagNumber(1)
  Billing ensureBilling() => $_ensure(0);
}

class BillingLookupRequest extends $pb.GeneratedMessage {
  factory BillingLookupRequest() => create();

  BillingLookupRequest._();

  factory BillingLookupRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory BillingLookupRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BillingLookupRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BillingLookupRequest clone() => BillingLookupRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BillingLookupRequest copyWith(void Function(BillingLookupRequest) updates) => super.copyWith((message) => updates(message as BillingLookupRequest)) as BillingLookupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BillingLookupRequest create() => BillingLookupRequest._();
  @$core.override
  BillingLookupRequest createEmptyInstance() => create();
  static $pb.PbList<BillingLookupRequest> createRepeated() => $pb.PbList<BillingLookupRequest>();
  @$core.pragma('dart2js:noInline')
  static BillingLookupRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BillingLookupRequest>(create);
  static BillingLookupRequest? _defaultInstance;
}

class BillingLookupResponse extends $pb.GeneratedMessage {
  factory BillingLookupResponse({
    Billing? billing,
  }) {
    final result = create();
    if (billing != null) result.billing = billing;
    return result;
  }

  BillingLookupResponse._();

  factory BillingLookupResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory BillingLookupResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BillingLookupResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..aOM<Billing>(1, _omitFieldNames ? '' : 'billing', subBuilder: Billing.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BillingLookupResponse clone() => BillingLookupResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BillingLookupResponse copyWith(void Function(BillingLookupResponse) updates) => super.copyWith((message) => updates(message as BillingLookupResponse)) as BillingLookupResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BillingLookupResponse create() => BillingLookupResponse._();
  @$core.override
  BillingLookupResponse createEmptyInstance() => create();
  static $pb.PbList<BillingLookupResponse> createRepeated() => $pb.PbList<BillingLookupResponse>();
  @$core.pragma('dart2js:noInline')
  static BillingLookupResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BillingLookupResponse>(create);
  static BillingLookupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Billing get billing => $_getN(0);
  @$pb.TagNumber(1)
  set billing(Billing value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBilling() => $_has(0);
  @$pb.TagNumber(1)
  void clearBilling() => $_clearField(1);
  @$pb.TagNumber(1)
  Billing ensureBilling() => $_ensure(0);
}

class BillingSubscribeRequest extends $pb.GeneratedMessage {
  factory BillingSubscribeRequest({
    $core.String? plan,
  }) {
    final result = create();
    if (plan != null) result.plan = plan;
    return result;
  }

  BillingSubscribeRequest._();

  factory BillingSubscribeRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory BillingSubscribeRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BillingSubscribeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'plan')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BillingSubscribeRequest clone() => BillingSubscribeRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BillingSubscribeRequest copyWith(void Function(BillingSubscribeRequest) updates) => super.copyWith((message) => updates(message as BillingSubscribeRequest)) as BillingSubscribeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BillingSubscribeRequest create() => BillingSubscribeRequest._();
  @$core.override
  BillingSubscribeRequest createEmptyInstance() => create();
  static $pb.PbList<BillingSubscribeRequest> createRepeated() => $pb.PbList<BillingSubscribeRequest>();
  @$core.pragma('dart2js:noInline')
  static BillingSubscribeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BillingSubscribeRequest>(create);
  static BillingSubscribeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get plan => $_getSZ(0);
  @$pb.TagNumber(1)
  set plan($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPlan() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlan() => $_clearField(1);
}

class BillingSubscribeResponse extends $pb.GeneratedMessage {
  factory BillingSubscribeResponse({
    Billing? billing,
  }) {
    final result = create();
    if (billing != null) result.billing = billing;
    return result;
  }

  BillingSubscribeResponse._();

  factory BillingSubscribeResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory BillingSubscribeResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BillingSubscribeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..aOM<Billing>(1, _omitFieldNames ? '' : 'billing', subBuilder: Billing.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BillingSubscribeResponse clone() => BillingSubscribeResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BillingSubscribeResponse copyWith(void Function(BillingSubscribeResponse) updates) => super.copyWith((message) => updates(message as BillingSubscribeResponse)) as BillingSubscribeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BillingSubscribeResponse create() => BillingSubscribeResponse._();
  @$core.override
  BillingSubscribeResponse createEmptyInstance() => create();
  static $pb.PbList<BillingSubscribeResponse> createRepeated() => $pb.PbList<BillingSubscribeResponse>();
  @$core.pragma('dart2js:noInline')
  static BillingSubscribeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BillingSubscribeResponse>(create);
  static BillingSubscribeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Billing get billing => $_getN(0);
  @$pb.TagNumber(1)
  set billing(Billing value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBilling() => $_has(0);
  @$pb.TagNumber(1)
  void clearBilling() => $_clearField(1);
  @$pb.TagNumber(1)
  Billing ensureBilling() => $_ensure(0);
}

class BillingSessionRequest extends $pb.GeneratedMessage {
  factory BillingSessionRequest({
    $core.String? plan,
  }) {
    final result = create();
    if (plan != null) result.plan = plan;
    return result;
  }

  BillingSessionRequest._();

  factory BillingSessionRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory BillingSessionRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BillingSessionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'plan')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BillingSessionRequest clone() => BillingSessionRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BillingSessionRequest copyWith(void Function(BillingSessionRequest) updates) => super.copyWith((message) => updates(message as BillingSessionRequest)) as BillingSessionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BillingSessionRequest create() => BillingSessionRequest._();
  @$core.override
  BillingSessionRequest createEmptyInstance() => create();
  static $pb.PbList<BillingSessionRequest> createRepeated() => $pb.PbList<BillingSessionRequest>();
  @$core.pragma('dart2js:noInline')
  static BillingSessionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BillingSessionRequest>(create);
  static BillingSessionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get plan => $_getSZ(0);
  @$pb.TagNumber(1)
  set plan($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPlan() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlan() => $_clearField(1);
}

class BillingSessionResponse extends $pb.GeneratedMessage {
  factory BillingSessionResponse({
    $core.String? redirect,
  }) {
    final result = create();
    if (redirect != null) result.redirect = redirect;
    return result;
  }

  BillingSessionResponse._();

  factory BillingSessionResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory BillingSessionResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BillingSessionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'redirect')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BillingSessionResponse clone() => BillingSessionResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BillingSessionResponse copyWith(void Function(BillingSessionResponse) updates) => super.copyWith((message) => updates(message as BillingSessionResponse)) as BillingSessionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BillingSessionResponse create() => BillingSessionResponse._();
  @$core.override
  BillingSessionResponse createEmptyInstance() => create();
  static $pb.PbList<BillingSessionResponse> createRepeated() => $pb.PbList<BillingSessionResponse>();
  @$core.pragma('dart2js:noInline')
  static BillingSessionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BillingSessionResponse>(create);
  static BillingSessionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get redirect => $_getSZ(0);
  @$pb.TagNumber(1)
  set redirect($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRedirect() => $_has(0);
  @$pb.TagNumber(1)
  void clearRedirect() => $_clearField(1);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
