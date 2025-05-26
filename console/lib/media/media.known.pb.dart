//
//  Generated code. Do not modify.
//  source: media.known.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Known extends $pb.GeneratedMessage {
  factory Known({
    $core.String? id,
    $core.String? description,
    $core.String? mimetype,
    $core.String? image,
    $core.String? archiveId,
    $core.String? torrentId,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? metadata,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (description != null) {
      $result.description = description;
    }
    if (mimetype != null) {
      $result.mimetype = mimetype;
    }
    if (image != null) {
      $result.image = image;
    }
    if (archiveId != null) {
      $result.archiveId = archiveId;
    }
    if (torrentId != null) {
      $result.torrentId = torrentId;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (updatedAt != null) {
      $result.updatedAt = updatedAt;
    }
    if (metadata != null) {
      $result.metadata = metadata;
    }
    return $result;
  }
  Known._() : super();
  factory Known.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Known.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Known', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aOS(3, _omitFieldNames ? '' : 'mimetype')
    ..aOS(4, _omitFieldNames ? '' : 'image')
    ..aOS(5, _omitFieldNames ? '' : 'archive_id')
    ..aOS(6, _omitFieldNames ? '' : 'torrent_id')
    ..aOS(7, _omitFieldNames ? '' : 'created_at')
    ..aOS(8, _omitFieldNames ? '' : 'updated_at')
    ..aOS(9, _omitFieldNames ? '' : 'metadata')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Known clone() => Known()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Known copyWith(void Function(Known) updates) => super.copyWith((message) => updates(message as Known)) as Known;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Known create() => Known._();
  Known createEmptyInstance() => create();
  static $pb.PbList<Known> createRepeated() => $pb.PbList<Known>();
  @$core.pragma('dart2js:noInline')
  static Known getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Known>(create);
  static Known? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get mimetype => $_getSZ(2);
  @$pb.TagNumber(3)
  set mimetype($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMimetype() => $_has(2);
  @$pb.TagNumber(3)
  void clearMimetype() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get image => $_getSZ(3);
  @$pb.TagNumber(4)
  set image($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasImage() => $_has(3);
  @$pb.TagNumber(4)
  void clearImage() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get archiveId => $_getSZ(4);
  @$pb.TagNumber(5)
  set archiveId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasArchiveId() => $_has(4);
  @$pb.TagNumber(5)
  void clearArchiveId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get torrentId => $_getSZ(5);
  @$pb.TagNumber(6)
  set torrentId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTorrentId() => $_has(5);
  @$pb.TagNumber(6)
  void clearTorrentId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get createdAt => $_getSZ(6);
  @$pb.TagNumber(7)
  set createdAt($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get updatedAt => $_getSZ(7);
  @$pb.TagNumber(8)
  set updatedAt($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasUpdatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearUpdatedAt() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get metadata => $_getSZ(8);
  @$pb.TagNumber(9)
  set metadata($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasMetadata() => $_has(8);
  @$pb.TagNumber(9)
  void clearMetadata() => $_clearField(9);
}

class KnownSearchRequest extends $pb.GeneratedMessage {
  factory KnownSearchRequest({
    $core.String? query,
    $fixnum.Int64? offset,
    $fixnum.Int64? limit,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (offset != null) {
      $result.offset = offset;
    }
    if (limit != null) {
      $result.limit = limit;
    }
    return $result;
  }
  KnownSearchRequest._() : super();
  factory KnownSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KnownSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KnownSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..a<$fixnum.Int64>(900, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(901, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownSearchRequest clone() => KnownSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownSearchRequest copyWith(void Function(KnownSearchRequest) updates) => super.copyWith((message) => updates(message as KnownSearchRequest)) as KnownSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KnownSearchRequest create() => KnownSearchRequest._();
  KnownSearchRequest createEmptyInstance() => create();
  static $pb.PbList<KnownSearchRequest> createRepeated() => $pb.PbList<KnownSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static KnownSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KnownSearchRequest>(create);
  static KnownSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(900)
  $fixnum.Int64 get offset => $_getI64(1);
  @$pb.TagNumber(900)
  set offset($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(900)
  $core.bool hasOffset() => $_has(1);
  @$pb.TagNumber(900)
  void clearOffset() => $_clearField(900);

  @$pb.TagNumber(901)
  $fixnum.Int64 get limit => $_getI64(2);
  @$pb.TagNumber(901)
  set limit($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(901)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(901)
  void clearLimit() => $_clearField(901);
}

class KnownSearchResponse extends $pb.GeneratedMessage {
  factory KnownSearchResponse({
    KnownSearchRequest? next,
    $core.Iterable<Known>? items,
  }) {
    final $result = create();
    if (next != null) {
      $result.next = next;
    }
    if (items != null) {
      $result.items.addAll(items);
    }
    return $result;
  }
  KnownSearchResponse._() : super();
  factory KnownSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KnownSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KnownSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..aOM<KnownSearchRequest>(1, _omitFieldNames ? '' : 'next', subBuilder: KnownSearchRequest.create)
    ..pc<Known>(2, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM, subBuilder: Known.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownSearchResponse clone() => KnownSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownSearchResponse copyWith(void Function(KnownSearchResponse) updates) => super.copyWith((message) => updates(message as KnownSearchResponse)) as KnownSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KnownSearchResponse create() => KnownSearchResponse._();
  KnownSearchResponse createEmptyInstance() => create();
  static $pb.PbList<KnownSearchResponse> createRepeated() => $pb.PbList<KnownSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static KnownSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KnownSearchResponse>(create);
  static KnownSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  KnownSearchRequest get next => $_getN(0);
  @$pb.TagNumber(1)
  set next(KnownSearchRequest v) { $_setField(1, v); }
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
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    return $result;
  }
  KnownMatchRequest._() : super();
  factory KnownMatchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KnownMatchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KnownMatchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownMatchRequest clone() => KnownMatchRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownMatchRequest copyWith(void Function(KnownMatchRequest) updates) => super.copyWith((message) => updates(message as KnownMatchRequest)) as KnownMatchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KnownMatchRequest create() => KnownMatchRequest._();
  KnownMatchRequest createEmptyInstance() => create();
  static $pb.PbList<KnownMatchRequest> createRepeated() => $pb.PbList<KnownMatchRequest>();
  @$core.pragma('dart2js:noInline')
  static KnownMatchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KnownMatchRequest>(create);
  static KnownMatchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);
}

class KnownLookupRequest extends $pb.GeneratedMessage {
  factory KnownLookupRequest() => create();
  KnownLookupRequest._() : super();
  factory KnownLookupRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KnownLookupRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KnownLookupRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownLookupRequest clone() => KnownLookupRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownLookupRequest copyWith(void Function(KnownLookupRequest) updates) => super.copyWith((message) => updates(message as KnownLookupRequest)) as KnownLookupRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KnownLookupRequest create() => KnownLookupRequest._();
  KnownLookupRequest createEmptyInstance() => create();
  static $pb.PbList<KnownLookupRequest> createRepeated() => $pb.PbList<KnownLookupRequest>();
  @$core.pragma('dart2js:noInline')
  static KnownLookupRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KnownLookupRequest>(create);
  static KnownLookupRequest? _defaultInstance;
}

class KnownLookupResponse extends $pb.GeneratedMessage {
  factory KnownLookupResponse({
    Known? known,
  }) {
    final $result = create();
    if (known != null) {
      $result.known = known;
    }
    return $result;
  }
  KnownLookupResponse._() : super();
  factory KnownLookupResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KnownLookupResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KnownLookupResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..aOM<Known>(1, _omitFieldNames ? '' : 'known', subBuilder: Known.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownLookupResponse clone() => KnownLookupResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownLookupResponse copyWith(void Function(KnownLookupResponse) updates) => super.copyWith((message) => updates(message as KnownLookupResponse)) as KnownLookupResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KnownLookupResponse create() => KnownLookupResponse._();
  KnownLookupResponse createEmptyInstance() => create();
  static $pb.PbList<KnownLookupResponse> createRepeated() => $pb.PbList<KnownLookupResponse>();
  @$core.pragma('dart2js:noInline')
  static KnownLookupResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KnownLookupResponse>(create);
  static KnownLookupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Known get known => $_getN(0);
  @$pb.TagNumber(1)
  set known(Known v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasKnown() => $_has(0);
  @$pb.TagNumber(1)
  void clearKnown() => $_clearField(1);
  @$pb.TagNumber(1)
  Known ensureKnown() => $_ensure(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
