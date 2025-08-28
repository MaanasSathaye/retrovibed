// This is a generated file - do not edit.
//
// Generated from community.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Community extends $pb.GeneratedMessage {
  factory Community({
    $core.String? id,
    $core.String? accountId,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? mimetype,
    $core.String? domain,
    $core.String? description,
    $core.String? entropy,
    $fixnum.Int64? bytes,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (accountId != null) result.accountId = accountId;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (mimetype != null) result.mimetype = mimetype;
    if (domain != null) result.domain = domain;
    if (description != null) result.description = description;
    if (entropy != null) result.entropy = entropy;
    if (bytes != null) result.bytes = bytes;
    return result;
  }

  Community._();

  factory Community.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Community.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Community',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'retrovibed.community'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'account_id')
    ..aOS(4, _omitFieldNames ? '' : 'created_at')
    ..aOS(5, _omitFieldNames ? '' : 'updated_at')
    ..aOS(6, _omitFieldNames ? '' : 'mimetype')
    ..aOS(7, _omitFieldNames ? '' : 'domain')
    ..aOS(8, _omitFieldNames ? '' : 'description')
    ..aOS(9, _omitFieldNames ? '' : 'entropy')
    ..a<$fixnum.Int64>(10, _omitFieldNames ? '' : 'bytes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Community clone() => Community()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Community copyWith(void Function(Community) updates) =>
      super.copyWith((message) => updates(message as Community)) as Community;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Community create() => Community._();
  @$core.override
  Community createEmptyInstance() => create();
  static $pb.PbList<Community> createRepeated() => $pb.PbList<Community>();
  @$core.pragma('dart2js:noInline')
  static Community getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Community>(create);
  static Community? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get accountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set accountId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccountId() => $_clearField(2);

  @$pb.TagNumber(4)
  $core.String get createdAt => $_getSZ(2);
  @$pb.TagNumber(4)
  set createdAt($core.String value) => $_setString(2, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatedAt() => $_has(2);
  @$pb.TagNumber(4)
  void clearCreatedAt() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get updatedAt => $_getSZ(3);
  @$pb.TagNumber(5)
  set updatedAt($core.String value) => $_setString(3, value);
  @$pb.TagNumber(5)
  $core.bool hasUpdatedAt() => $_has(3);
  @$pb.TagNumber(5)
  void clearUpdatedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get mimetype => $_getSZ(4);
  @$pb.TagNumber(6)
  set mimetype($core.String value) => $_setString(4, value);
  @$pb.TagNumber(6)
  $core.bool hasMimetype() => $_has(4);
  @$pb.TagNumber(6)
  void clearMimetype() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get domain => $_getSZ(5);
  @$pb.TagNumber(7)
  set domain($core.String value) => $_setString(5, value);
  @$pb.TagNumber(7)
  $core.bool hasDomain() => $_has(5);
  @$pb.TagNumber(7)
  void clearDomain() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get description => $_getSZ(6);
  @$pb.TagNumber(8)
  set description($core.String value) => $_setString(6, value);
  @$pb.TagNumber(8)
  $core.bool hasDescription() => $_has(6);
  @$pb.TagNumber(8)
  void clearDescription() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get entropy => $_getSZ(7);
  @$pb.TagNumber(9)
  set entropy($core.String value) => $_setString(7, value);
  @$pb.TagNumber(9)
  $core.bool hasEntropy() => $_has(7);
  @$pb.TagNumber(9)
  void clearEntropy() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get bytes => $_getI64(8);
  @$pb.TagNumber(10)
  set bytes($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(10)
  $core.bool hasBytes() => $_has(8);
  @$pb.TagNumber(10)
  void clearBytes() => $_clearField(10);
}

class CommunitySearchRequest extends $pb.GeneratedMessage {
  factory CommunitySearchRequest({
    $core.String? query,
    $fixnum.Int64? offset,
    $fixnum.Int64? limit,
  }) {
    final result = create();
    if (query != null) result.query = query;
    if (offset != null) result.offset = offset;
    if (limit != null) result.limit = limit;
    return result;
  }

  CommunitySearchRequest._();

  factory CommunitySearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CommunitySearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommunitySearchRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'retrovibed.community'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommunitySearchRequest clone() =>
      CommunitySearchRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommunitySearchRequest copyWith(
          void Function(CommunitySearchRequest) updates) =>
      super.copyWith((message) => updates(message as CommunitySearchRequest))
          as CommunitySearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommunitySearchRequest create() => CommunitySearchRequest._();
  @$core.override
  CommunitySearchRequest createEmptyInstance() => create();
  static $pb.PbList<CommunitySearchRequest> createRepeated() =>
      $pb.PbList<CommunitySearchRequest>();
  @$core.pragma('dart2js:noInline')
  static CommunitySearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommunitySearchRequest>(create);
  static CommunitySearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get offset => $_getI64(1);
  @$pb.TagNumber(2)
  set offset($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOffset() => $_has(1);
  @$pb.TagNumber(2)
  void clearOffset() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get limit => $_getI64(2);
  @$pb.TagNumber(3)
  set limit($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);
}

class CommunitySearchResponse extends $pb.GeneratedMessage {
  factory CommunitySearchResponse({
    CommunitySearchRequest? next,
    $core.Iterable<Community>? items,
  }) {
    final result = create();
    if (next != null) result.next = next;
    if (items != null) result.items.addAll(items);
    return result;
  }

  CommunitySearchResponse._();

  factory CommunitySearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CommunitySearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommunitySearchResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'retrovibed.community'),
      createEmptyInstance: create)
    ..aOM<CommunitySearchRequest>(1, _omitFieldNames ? '' : 'next',
        subBuilder: CommunitySearchRequest.create)
    ..pc<Community>(2, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM,
        subBuilder: Community.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommunitySearchResponse clone() =>
      CommunitySearchResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommunitySearchResponse copyWith(
          void Function(CommunitySearchResponse) updates) =>
      super.copyWith((message) => updates(message as CommunitySearchResponse))
          as CommunitySearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommunitySearchResponse create() => CommunitySearchResponse._();
  @$core.override
  CommunitySearchResponse createEmptyInstance() => create();
  static $pb.PbList<CommunitySearchResponse> createRepeated() =>
      $pb.PbList<CommunitySearchResponse>();
  @$core.pragma('dart2js:noInline')
  static CommunitySearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommunitySearchResponse>(create);
  static CommunitySearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  CommunitySearchRequest get next => $_getN(0);
  @$pb.TagNumber(1)
  set next(CommunitySearchRequest value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasNext() => $_has(0);
  @$pb.TagNumber(1)
  void clearNext() => $_clearField(1);
  @$pb.TagNumber(1)
  CommunitySearchRequest ensureNext() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<Community> get items => $_getList(1);
}

class CommunityCreateRequest extends $pb.GeneratedMessage {
  factory CommunityCreateRequest({
    Community? community,
  }) {
    final result = create();
    if (community != null) result.community = community;
    return result;
  }

  CommunityCreateRequest._();

  factory CommunityCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CommunityCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommunityCreateRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'retrovibed.community'),
      createEmptyInstance: create)
    ..aOM<Community>(1, _omitFieldNames ? '' : 'community',
        subBuilder: Community.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommunityCreateRequest clone() =>
      CommunityCreateRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommunityCreateRequest copyWith(
          void Function(CommunityCreateRequest) updates) =>
      super.copyWith((message) => updates(message as CommunityCreateRequest))
          as CommunityCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommunityCreateRequest create() => CommunityCreateRequest._();
  @$core.override
  CommunityCreateRequest createEmptyInstance() => create();
  static $pb.PbList<CommunityCreateRequest> createRepeated() =>
      $pb.PbList<CommunityCreateRequest>();
  @$core.pragma('dart2js:noInline')
  static CommunityCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommunityCreateRequest>(create);
  static CommunityCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Community get community => $_getN(0);
  @$pb.TagNumber(1)
  set community(Community value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCommunity() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommunity() => $_clearField(1);
  @$pb.TagNumber(1)
  Community ensureCommunity() => $_ensure(0);
}

class CommunityCreateResponse extends $pb.GeneratedMessage {
  factory CommunityCreateResponse({
    Community? community,
  }) {
    final result = create();
    if (community != null) result.community = community;
    return result;
  }

  CommunityCreateResponse._();

  factory CommunityCreateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CommunityCreateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommunityCreateResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'retrovibed.community'),
      createEmptyInstance: create)
    ..aOM<Community>(1, _omitFieldNames ? '' : 'community',
        subBuilder: Community.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommunityCreateResponse clone() =>
      CommunityCreateResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommunityCreateResponse copyWith(
          void Function(CommunityCreateResponse) updates) =>
      super.copyWith((message) => updates(message as CommunityCreateResponse))
          as CommunityCreateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommunityCreateResponse create() => CommunityCreateResponse._();
  @$core.override
  CommunityCreateResponse createEmptyInstance() => create();
  static $pb.PbList<CommunityCreateResponse> createRepeated() =>
      $pb.PbList<CommunityCreateResponse>();
  @$core.pragma('dart2js:noInline')
  static CommunityCreateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommunityCreateResponse>(create);
  static CommunityCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Community get community => $_getN(0);
  @$pb.TagNumber(1)
  set community(Community value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCommunity() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommunity() => $_clearField(1);
  @$pb.TagNumber(1)
  Community ensureCommunity() => $_ensure(0);
}

class CommunityFindRequest extends $pb.GeneratedMessage {
  factory CommunityFindRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  CommunityFindRequest._();

  factory CommunityFindRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CommunityFindRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommunityFindRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'retrovibed.community'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommunityFindRequest clone() =>
      CommunityFindRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommunityFindRequest copyWith(void Function(CommunityFindRequest) updates) =>
      super.copyWith((message) => updates(message as CommunityFindRequest))
          as CommunityFindRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommunityFindRequest create() => CommunityFindRequest._();
  @$core.override
  CommunityFindRequest createEmptyInstance() => create();
  static $pb.PbList<CommunityFindRequest> createRepeated() =>
      $pb.PbList<CommunityFindRequest>();
  @$core.pragma('dart2js:noInline')
  static CommunityFindRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommunityFindRequest>(create);
  static CommunityFindRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class CommunityFindResponse extends $pb.GeneratedMessage {
  factory CommunityFindResponse({
    Community? community,
  }) {
    final result = create();
    if (community != null) result.community = community;
    return result;
  }

  CommunityFindResponse._();

  factory CommunityFindResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CommunityFindResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommunityFindResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'retrovibed.community'),
      createEmptyInstance: create)
    ..aOM<Community>(1, _omitFieldNames ? '' : 'community',
        subBuilder: Community.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommunityFindResponse clone() =>
      CommunityFindResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommunityFindResponse copyWith(
          void Function(CommunityFindResponse) updates) =>
      super.copyWith((message) => updates(message as CommunityFindResponse))
          as CommunityFindResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommunityFindResponse create() => CommunityFindResponse._();
  @$core.override
  CommunityFindResponse createEmptyInstance() => create();
  static $pb.PbList<CommunityFindResponse> createRepeated() =>
      $pb.PbList<CommunityFindResponse>();
  @$core.pragma('dart2js:noInline')
  static CommunityFindResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommunityFindResponse>(create);
  static CommunityFindResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Community get community => $_getN(0);
  @$pb.TagNumber(1)
  set community(Community value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCommunity() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommunity() => $_clearField(1);
  @$pb.TagNumber(1)
  Community ensureCommunity() => $_ensure(0);
}

class CommunityUploadRequest extends $pb.GeneratedMessage {
  factory CommunityUploadRequest({
    Community? community,
  }) {
    final result = create();
    if (community != null) result.community = community;
    return result;
  }

  CommunityUploadRequest._();

  factory CommunityUploadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CommunityUploadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommunityUploadRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'retrovibed.community'),
      createEmptyInstance: create)
    ..aOM<Community>(1, _omitFieldNames ? '' : 'community',
        subBuilder: Community.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommunityUploadRequest clone() =>
      CommunityUploadRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommunityUploadRequest copyWith(
          void Function(CommunityUploadRequest) updates) =>
      super.copyWith((message) => updates(message as CommunityUploadRequest))
          as CommunityUploadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommunityUploadRequest create() => CommunityUploadRequest._();
  @$core.override
  CommunityUploadRequest createEmptyInstance() => create();
  static $pb.PbList<CommunityUploadRequest> createRepeated() =>
      $pb.PbList<CommunityUploadRequest>();
  @$core.pragma('dart2js:noInline')
  static CommunityUploadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommunityUploadRequest>(create);
  static CommunityUploadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Community get community => $_getN(0);
  @$pb.TagNumber(1)
  set community(Community value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCommunity() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommunity() => $_clearField(1);
  @$pb.TagNumber(1)
  Community ensureCommunity() => $_ensure(0);
}

class CommunityUploadResponse extends $pb.GeneratedMessage {
  factory CommunityUploadResponse({
    Community? community,
  }) {
    final result = create();
    if (community != null) result.community = community;
    return result;
  }

  CommunityUploadResponse._();

  factory CommunityUploadResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CommunityUploadResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommunityUploadResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'retrovibed.community'),
      createEmptyInstance: create)
    ..aOM<Community>(1, _omitFieldNames ? '' : 'community',
        subBuilder: Community.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommunityUploadResponse clone() =>
      CommunityUploadResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommunityUploadResponse copyWith(
          void Function(CommunityUploadResponse) updates) =>
      super.copyWith((message) => updates(message as CommunityUploadResponse))
          as CommunityUploadResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommunityUploadResponse create() => CommunityUploadResponse._();
  @$core.override
  CommunityUploadResponse createEmptyInstance() => create();
  static $pb.PbList<CommunityUploadResponse> createRepeated() =>
      $pb.PbList<CommunityUploadResponse>();
  @$core.pragma('dart2js:noInline')
  static CommunityUploadResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommunityUploadResponse>(create);
  static CommunityUploadResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Community get community => $_getN(0);
  @$pb.TagNumber(1)
  set community(Community value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCommunity() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommunity() => $_clearField(1);
  @$pb.TagNumber(1)
  Community ensureCommunity() => $_ensure(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
