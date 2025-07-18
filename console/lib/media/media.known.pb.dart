// This is a generated file - do not edit.
//
// Generated from media.known.proto.

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

class Known extends $pb.GeneratedMessage {
  factory Known({
    $core.String? id,
    $core.double? rating,
    $core.bool? adult,
    $core.String? description,
    $core.String? summary,
    $core.String? image,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (rating != null) result.rating = rating;
    if (adult != null) result.adult = adult;
    if (description != null) result.description = description;
    if (summary != null) result.summary = summary;
    if (image != null) result.image = image;
    return result;
  }

  Known._();

  factory Known.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Known.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Known',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'media'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'rating', $pb.PbFieldType.OF)
    ..aOB(3, _omitFieldNames ? '' : 'adult')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOS(5, _omitFieldNames ? '' : 'summary')
    ..aOS(6, _omitFieldNames ? '' : 'image')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Known clone() => Known()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Known copyWith(void Function(Known) updates) =>
      super.copyWith((message) => updates(message as Known)) as Known;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Known create() => Known._();
  @$core.override
  Known createEmptyInstance() => create();
  static $pb.PbList<Known> createRepeated() => $pb.PbList<Known>();
  @$core.pragma('dart2js:noInline')
  static Known getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Known>(create);
  static Known? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get rating => $_getN(1);
  @$pb.TagNumber(2)
  set rating($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRating() => $_has(1);
  @$pb.TagNumber(2)
  void clearRating() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get adult => $_getBF(2);
  @$pb.TagNumber(3)
  set adult($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAdult() => $_has(2);
  @$pb.TagNumber(3)
  void clearAdult() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get summary => $_getSZ(4);
  @$pb.TagNumber(5)
  set summary($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSummary() => $_has(4);
  @$pb.TagNumber(5)
  void clearSummary() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get image => $_getSZ(5);
  @$pb.TagNumber(6)
  set image($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasImage() => $_has(5);
  @$pb.TagNumber(6)
  void clearImage() => $_clearField(6);
}

class KnownSearchRequest extends $pb.GeneratedMessage {
  factory KnownSearchRequest({
    $core.String? query,
    $core.bool? adult,
    $fixnum.Int64? offset,
    $fixnum.Int64? limit,
  }) {
    final result = create();
    if (query != null) result.query = query;
    if (adult != null) result.adult = adult;
    if (offset != null) result.offset = offset;
    if (limit != null) result.limit = limit;
    return result;
  }

  KnownSearchRequest._();

  factory KnownSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory KnownSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'KnownSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'media'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOB(2, _omitFieldNames ? '' : 'adult')
    ..a<$fixnum.Int64>(
        900, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(901, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownSearchRequest clone() => KnownSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownSearchRequest copyWith(void Function(KnownSearchRequest) updates) =>
      super.copyWith((message) => updates(message as KnownSearchRequest))
          as KnownSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KnownSearchRequest create() => KnownSearchRequest._();
  @$core.override
  KnownSearchRequest createEmptyInstance() => create();
  static $pb.PbList<KnownSearchRequest> createRepeated() =>
      $pb.PbList<KnownSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static KnownSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<KnownSearchRequest>(create);
  static KnownSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get adult => $_getBF(1);
  @$pb.TagNumber(2)
  set adult($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAdult() => $_has(1);
  @$pb.TagNumber(2)
  void clearAdult() => $_clearField(2);

  @$pb.TagNumber(900)
  $fixnum.Int64 get offset => $_getI64(2);
  @$pb.TagNumber(900)
  set offset($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(900)
  $core.bool hasOffset() => $_has(2);
  @$pb.TagNumber(900)
  void clearOffset() => $_clearField(900);

  @$pb.TagNumber(901)
  $fixnum.Int64 get limit => $_getI64(3);
  @$pb.TagNumber(901)
  set limit($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(901)
  $core.bool hasLimit() => $_has(3);
  @$pb.TagNumber(901)
  void clearLimit() => $_clearField(901);
}

class KnownSearchResponse extends $pb.GeneratedMessage {
  factory KnownSearchResponse({
    KnownSearchRequest? next,
    $core.Iterable<Known>? items,
  }) {
    final result = create();
    if (next != null) result.next = next;
    if (items != null) result.items.addAll(items);
    return result;
  }

  KnownSearchResponse._();

  factory KnownSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory KnownSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'KnownSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'media'),
      createEmptyInstance: create)
    ..aOM<KnownSearchRequest>(1, _omitFieldNames ? '' : 'next',
        subBuilder: KnownSearchRequest.create)
    ..pc<Known>(2, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM,
        subBuilder: Known.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownSearchResponse clone() => KnownSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownSearchResponse copyWith(void Function(KnownSearchResponse) updates) =>
      super.copyWith((message) => updates(message as KnownSearchResponse))
          as KnownSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KnownSearchResponse create() => KnownSearchResponse._();
  @$core.override
  KnownSearchResponse createEmptyInstance() => create();
  static $pb.PbList<KnownSearchResponse> createRepeated() =>
      $pb.PbList<KnownSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static KnownSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<KnownSearchResponse>(create);
  static KnownSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  KnownSearchRequest get next => $_getN(0);
  @$pb.TagNumber(1)
  set next(KnownSearchRequest value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasNext() => $_has(0);
  @$pb.TagNumber(1)
  void clearNext() => $_clearField(1);
  @$pb.TagNumber(1)
  KnownSearchRequest ensureNext() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<Known> get items => $_getList(1);
}

class KnownMatchRequest extends $pb.GeneratedMessage {
  factory KnownMatchRequest({
    $core.String? query,
  }) {
    final result = create();
    if (query != null) result.query = query;
    return result;
  }

  KnownMatchRequest._();

  factory KnownMatchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory KnownMatchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'KnownMatchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'media'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownMatchRequest clone() => KnownMatchRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownMatchRequest copyWith(void Function(KnownMatchRequest) updates) =>
      super.copyWith((message) => updates(message as KnownMatchRequest))
          as KnownMatchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KnownMatchRequest create() => KnownMatchRequest._();
  @$core.override
  KnownMatchRequest createEmptyInstance() => create();
  static $pb.PbList<KnownMatchRequest> createRepeated() =>
      $pb.PbList<KnownMatchRequest>();
  @$core.pragma('dart2js:noInline')
  static KnownMatchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<KnownMatchRequest>(create);
  static KnownMatchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);
}

class KnownLookupRequest extends $pb.GeneratedMessage {
  factory KnownLookupRequest() => create();

  KnownLookupRequest._();

  factory KnownLookupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory KnownLookupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'KnownLookupRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'media'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownLookupRequest clone() => KnownLookupRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownLookupRequest copyWith(void Function(KnownLookupRequest) updates) =>
      super.copyWith((message) => updates(message as KnownLookupRequest))
          as KnownLookupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KnownLookupRequest create() => KnownLookupRequest._();
  @$core.override
  KnownLookupRequest createEmptyInstance() => create();
  static $pb.PbList<KnownLookupRequest> createRepeated() =>
      $pb.PbList<KnownLookupRequest>();
  @$core.pragma('dart2js:noInline')
  static KnownLookupRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<KnownLookupRequest>(create);
  static KnownLookupRequest? _defaultInstance;
}

class KnownLookupResponse extends $pb.GeneratedMessage {
  factory KnownLookupResponse({
    Known? known,
  }) {
    final result = create();
    if (known != null) result.known = known;
    return result;
  }

  KnownLookupResponse._();

  factory KnownLookupResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory KnownLookupResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'KnownLookupResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'media'),
      createEmptyInstance: create)
    ..aOM<Known>(1, _omitFieldNames ? '' : 'known', subBuilder: Known.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownLookupResponse clone() => KnownLookupResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownLookupResponse copyWith(void Function(KnownLookupResponse) updates) =>
      super.copyWith((message) => updates(message as KnownLookupResponse))
          as KnownLookupResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KnownLookupResponse create() => KnownLookupResponse._();
  @$core.override
  KnownLookupResponse createEmptyInstance() => create();
  static $pb.PbList<KnownLookupResponse> createRepeated() =>
      $pb.PbList<KnownLookupResponse>();
  @$core.pragma('dart2js:noInline')
  static KnownLookupResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<KnownLookupResponse>(create);
  static KnownLookupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Known get known => $_getN(0);
  @$pb.TagNumber(1)
  set known(Known value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasKnown() => $_has(0);
  @$pb.TagNumber(1)
  void clearKnown() => $_clearField(1);
  @$pb.TagNumber(1)
  Known ensureKnown() => $_ensure(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
