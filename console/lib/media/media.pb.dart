// This is a generated file - do not edit.
//
// Generated from media.proto.

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

class Media extends $pb.GeneratedMessage {
  factory Media({
    $core.String? id,
    $core.String? description,
    $core.String? mimetype,
    $core.String? image,
    $core.String? archiveId,
    $core.String? torrentId,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? knownMediaId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (description != null) result.description = description;
    if (mimetype != null) result.mimetype = mimetype;
    if (image != null) result.image = image;
    if (archiveId != null) result.archiveId = archiveId;
    if (torrentId != null) result.torrentId = torrentId;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (knownMediaId != null) result.knownMediaId = knownMediaId;
    return result;
  }

  Media._();

  factory Media.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory Media.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Media', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aOS(3, _omitFieldNames ? '' : 'mimetype')
    ..aOS(4, _omitFieldNames ? '' : 'image')
    ..aOS(5, _omitFieldNames ? '' : 'archive_id')
    ..aOS(6, _omitFieldNames ? '' : 'torrent_id')
    ..aOS(7, _omitFieldNames ? '' : 'created_at')
    ..aOS(8, _omitFieldNames ? '' : 'updated_at')
    ..aOS(9, _omitFieldNames ? '' : 'known_media_id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Media clone() => Media()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Media copyWith(void Function(Media) updates) => super.copyWith((message) => updates(message as Media)) as Media;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Media create() => Media._();
  @$core.override
  Media createEmptyInstance() => create();
  static $pb.PbList<Media> createRepeated() => $pb.PbList<Media>();
  @$core.pragma('dart2js:noInline')
  static Media getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Media>(create);
  static Media? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get mimetype => $_getSZ(2);
  @$pb.TagNumber(3)
  set mimetype($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMimetype() => $_has(2);
  @$pb.TagNumber(3)
  void clearMimetype() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get image => $_getSZ(3);
  @$pb.TagNumber(4)
  set image($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasImage() => $_has(3);
  @$pb.TagNumber(4)
  void clearImage() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get archiveId => $_getSZ(4);
  @$pb.TagNumber(5)
  set archiveId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasArchiveId() => $_has(4);
  @$pb.TagNumber(5)
  void clearArchiveId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get torrentId => $_getSZ(5);
  @$pb.TagNumber(6)
  set torrentId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTorrentId() => $_has(5);
  @$pb.TagNumber(6)
  void clearTorrentId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get createdAt => $_getSZ(6);
  @$pb.TagNumber(7)
  set createdAt($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get updatedAt => $_getSZ(7);
  @$pb.TagNumber(8)
  set updatedAt($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUpdatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearUpdatedAt() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get knownMediaId => $_getSZ(8);
  @$pb.TagNumber(9)
  set knownMediaId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasKnownMediaId() => $_has(8);
  @$pb.TagNumber(9)
  void clearKnownMediaId() => $_clearField(9);
}

class MediaSearchRequest extends $pb.GeneratedMessage {
  factory MediaSearchRequest({
    $core.String? query,
    $core.Iterable<$core.String>? mimetypes,
    $fixnum.Int64? offset,
    $fixnum.Int64? limit,
  }) {
    final result = create();
    if (query != null) result.query = query;
    if (mimetypes != null) result.mimetypes.addAll(mimetypes);
    if (offset != null) result.offset = offset;
    if (limit != null) result.limit = limit;
    return result;
  }

  MediaSearchRequest._();

  factory MediaSearchRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MediaSearchRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MediaSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..pPS(2, _omitFieldNames ? '' : 'mimetypes')
    ..a<$fixnum.Int64>(900, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(901, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MediaSearchRequest clone() => MediaSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MediaSearchRequest copyWith(void Function(MediaSearchRequest) updates) => super.copyWith((message) => updates(message as MediaSearchRequest)) as MediaSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MediaSearchRequest create() => MediaSearchRequest._();
  @$core.override
  MediaSearchRequest createEmptyInstance() => create();
  static $pb.PbList<MediaSearchRequest> createRepeated() => $pb.PbList<MediaSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static MediaSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MediaSearchRequest>(create);
  static MediaSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get mimetypes => $_getList(1);

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

class MediaSearchResponse extends $pb.GeneratedMessage {
  factory MediaSearchResponse({
    MediaSearchRequest? next,
    $core.Iterable<Media>? items,
  }) {
    final result = create();
    if (next != null) result.next = next;
    if (items != null) result.items.addAll(items);
    return result;
  }

  MediaSearchResponse._();

  factory MediaSearchResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MediaSearchResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MediaSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..aOM<MediaSearchRequest>(1, _omitFieldNames ? '' : 'next', subBuilder: MediaSearchRequest.create)
    ..pc<Media>(2, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM, subBuilder: Media.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MediaSearchResponse clone() => MediaSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MediaSearchResponse copyWith(void Function(MediaSearchResponse) updates) => super.copyWith((message) => updates(message as MediaSearchResponse)) as MediaSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MediaSearchResponse create() => MediaSearchResponse._();
  @$core.override
  MediaSearchResponse createEmptyInstance() => create();
  static $pb.PbList<MediaSearchResponse> createRepeated() => $pb.PbList<MediaSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static MediaSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MediaSearchResponse>(create);
  static MediaSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MediaSearchRequest get next => $_getN(0);
  @$pb.TagNumber(1)
  set next(MediaSearchRequest value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasNext() => $_has(0);
  @$pb.TagNumber(1)
  void clearNext() => $_clearField(1);
  @$pb.TagNumber(1)
  MediaSearchRequest ensureNext() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<Media> get items => $_getList(1);
}

class MediaUpdateRequest extends $pb.GeneratedMessage {
  factory MediaUpdateRequest({
    Media? media,
  }) {
    final result = create();
    if (media != null) result.media = media;
    return result;
  }

  MediaUpdateRequest._();

  factory MediaUpdateRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MediaUpdateRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MediaUpdateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..aOM<Media>(1, _omitFieldNames ? '' : 'media', subBuilder: Media.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MediaUpdateRequest clone() => MediaUpdateRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MediaUpdateRequest copyWith(void Function(MediaUpdateRequest) updates) => super.copyWith((message) => updates(message as MediaUpdateRequest)) as MediaUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MediaUpdateRequest create() => MediaUpdateRequest._();
  @$core.override
  MediaUpdateRequest createEmptyInstance() => create();
  static $pb.PbList<MediaUpdateRequest> createRepeated() => $pb.PbList<MediaUpdateRequest>();
  @$core.pragma('dart2js:noInline')
  static MediaUpdateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MediaUpdateRequest>(create);
  static MediaUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Media get media => $_getN(0);
  @$pb.TagNumber(1)
  set media(Media value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMedia() => $_has(0);
  @$pb.TagNumber(1)
  void clearMedia() => $_clearField(1);
  @$pb.TagNumber(1)
  Media ensureMedia() => $_ensure(0);
}

class MediaUpdateResponse extends $pb.GeneratedMessage {
  factory MediaUpdateResponse({
    Media? media,
  }) {
    final result = create();
    if (media != null) result.media = media;
    return result;
  }

  MediaUpdateResponse._();

  factory MediaUpdateResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MediaUpdateResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MediaUpdateResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..aOM<Media>(1, _omitFieldNames ? '' : 'media', subBuilder: Media.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MediaUpdateResponse clone() => MediaUpdateResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MediaUpdateResponse copyWith(void Function(MediaUpdateResponse) updates) => super.copyWith((message) => updates(message as MediaUpdateResponse)) as MediaUpdateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MediaUpdateResponse create() => MediaUpdateResponse._();
  @$core.override
  MediaUpdateResponse createEmptyInstance() => create();
  static $pb.PbList<MediaUpdateResponse> createRepeated() => $pb.PbList<MediaUpdateResponse>();
  @$core.pragma('dart2js:noInline')
  static MediaUpdateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MediaUpdateResponse>(create);
  static MediaUpdateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Media get media => $_getN(0);
  @$pb.TagNumber(1)
  set media(Media value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMedia() => $_has(0);
  @$pb.TagNumber(1)
  void clearMedia() => $_clearField(1);
  @$pb.TagNumber(1)
  Media ensureMedia() => $_ensure(0);
}

class MediaDeleteRequest extends $pb.GeneratedMessage {
  factory MediaDeleteRequest() => create();

  MediaDeleteRequest._();

  factory MediaDeleteRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MediaDeleteRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MediaDeleteRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MediaDeleteRequest clone() => MediaDeleteRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MediaDeleteRequest copyWith(void Function(MediaDeleteRequest) updates) => super.copyWith((message) => updates(message as MediaDeleteRequest)) as MediaDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MediaDeleteRequest create() => MediaDeleteRequest._();
  @$core.override
  MediaDeleteRequest createEmptyInstance() => create();
  static $pb.PbList<MediaDeleteRequest> createRepeated() => $pb.PbList<MediaDeleteRequest>();
  @$core.pragma('dart2js:noInline')
  static MediaDeleteRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MediaDeleteRequest>(create);
  static MediaDeleteRequest? _defaultInstance;
}

class MediaDeleteResponse extends $pb.GeneratedMessage {
  factory MediaDeleteResponse({
    Media? media,
  }) {
    final result = create();
    if (media != null) result.media = media;
    return result;
  }

  MediaDeleteResponse._();

  factory MediaDeleteResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MediaDeleteResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MediaDeleteResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..aOM<Media>(1, _omitFieldNames ? '' : 'media', subBuilder: Media.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MediaDeleteResponse clone() => MediaDeleteResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MediaDeleteResponse copyWith(void Function(MediaDeleteResponse) updates) => super.copyWith((message) => updates(message as MediaDeleteResponse)) as MediaDeleteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MediaDeleteResponse create() => MediaDeleteResponse._();
  @$core.override
  MediaDeleteResponse createEmptyInstance() => create();
  static $pb.PbList<MediaDeleteResponse> createRepeated() => $pb.PbList<MediaDeleteResponse>();
  @$core.pragma('dart2js:noInline')
  static MediaDeleteResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MediaDeleteResponse>(create);
  static MediaDeleteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Media get media => $_getN(0);
  @$pb.TagNumber(1)
  set media(Media value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMedia() => $_has(0);
  @$pb.TagNumber(1)
  void clearMedia() => $_clearField(1);
  @$pb.TagNumber(1)
  Media ensureMedia() => $_ensure(0);
}

class MediaUploadResponse extends $pb.GeneratedMessage {
  factory MediaUploadResponse({
    Media? media,
  }) {
    final result = create();
    if (media != null) result.media = media;
    return result;
  }

  MediaUploadResponse._();

  factory MediaUploadResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MediaUploadResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MediaUploadResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..aOM<Media>(1, _omitFieldNames ? '' : 'media', subBuilder: Media.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MediaUploadResponse clone() => MediaUploadResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MediaUploadResponse copyWith(void Function(MediaUploadResponse) updates) => super.copyWith((message) => updates(message as MediaUploadResponse)) as MediaUploadResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MediaUploadResponse create() => MediaUploadResponse._();
  @$core.override
  MediaUploadResponse createEmptyInstance() => create();
  static $pb.PbList<MediaUploadResponse> createRepeated() => $pb.PbList<MediaUploadResponse>();
  @$core.pragma('dart2js:noInline')
  static MediaUploadResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MediaUploadResponse>(create);
  static MediaUploadResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Media get media => $_getN(0);
  @$pb.TagNumber(1)
  set media(Media value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMedia() => $_has(0);
  @$pb.TagNumber(1)
  void clearMedia() => $_clearField(1);
  @$pb.TagNumber(1)
  Media ensureMedia() => $_ensure(0);
}

class Download extends $pb.GeneratedMessage {
  factory Download({
    Media? media,
    $fixnum.Int64? bytes,
    $fixnum.Int64? downloaded,
    $core.String? initiatedAt,
    $core.String? pausedAt,
    $core.int? peers,
  }) {
    final result = create();
    if (media != null) result.media = media;
    if (bytes != null) result.bytes = bytes;
    if (downloaded != null) result.downloaded = downloaded;
    if (initiatedAt != null) result.initiatedAt = initiatedAt;
    if (pausedAt != null) result.pausedAt = pausedAt;
    if (peers != null) result.peers = peers;
    return result;
  }

  Download._();

  factory Download.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory Download.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Download', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..aOM<Media>(1, _omitFieldNames ? '' : 'media', subBuilder: Media.create)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'bytes', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'downloaded', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(4, _omitFieldNames ? '' : 'initiated_at')
    ..aOS(5, _omitFieldNames ? '' : 'paused_at')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'peers', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Download clone() => Download()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Download copyWith(void Function(Download) updates) => super.copyWith((message) => updates(message as Download)) as Download;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Download create() => Download._();
  @$core.override
  Download createEmptyInstance() => create();
  static $pb.PbList<Download> createRepeated() => $pb.PbList<Download>();
  @$core.pragma('dart2js:noInline')
  static Download getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Download>(create);
  static Download? _defaultInstance;

  @$pb.TagNumber(1)
  Media get media => $_getN(0);
  @$pb.TagNumber(1)
  set media(Media value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMedia() => $_has(0);
  @$pb.TagNumber(1)
  void clearMedia() => $_clearField(1);
  @$pb.TagNumber(1)
  Media ensureMedia() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get bytes => $_getI64(1);
  @$pb.TagNumber(2)
  set bytes($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBytes() => $_has(1);
  @$pb.TagNumber(2)
  void clearBytes() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get downloaded => $_getI64(2);
  @$pb.TagNumber(3)
  set downloaded($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDownloaded() => $_has(2);
  @$pb.TagNumber(3)
  void clearDownloaded() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get initiatedAt => $_getSZ(3);
  @$pb.TagNumber(4)
  set initiatedAt($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInitiatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearInitiatedAt() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get pausedAt => $_getSZ(4);
  @$pb.TagNumber(5)
  set pausedAt($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPausedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearPausedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get peers => $_getIZ(5);
  @$pb.TagNumber(6)
  set peers($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPeers() => $_has(5);
  @$pb.TagNumber(6)
  void clearPeers() => $_clearField(6);
}

class DownloadSearchRequest extends $pb.GeneratedMessage {
  factory DownloadSearchRequest({
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

  DownloadSearchRequest._();

  factory DownloadSearchRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory DownloadSearchRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..a<$fixnum.Int64>(900, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(901, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadSearchRequest clone() => DownloadSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadSearchRequest copyWith(void Function(DownloadSearchRequest) updates) => super.copyWith((message) => updates(message as DownloadSearchRequest)) as DownloadSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadSearchRequest create() => DownloadSearchRequest._();
  @$core.override
  DownloadSearchRequest createEmptyInstance() => create();
  static $pb.PbList<DownloadSearchRequest> createRepeated() => $pb.PbList<DownloadSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static DownloadSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DownloadSearchRequest>(create);
  static DownloadSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(900)
  $fixnum.Int64 get offset => $_getI64(1);
  @$pb.TagNumber(900)
  set offset($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(900)
  $core.bool hasOffset() => $_has(1);
  @$pb.TagNumber(900)
  void clearOffset() => $_clearField(900);

  @$pb.TagNumber(901)
  $fixnum.Int64 get limit => $_getI64(2);
  @$pb.TagNumber(901)
  set limit($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(901)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(901)
  void clearLimit() => $_clearField(901);
}

class DownloadSearchResponse extends $pb.GeneratedMessage {
  factory DownloadSearchResponse({
    DownloadSearchRequest? next,
    $core.Iterable<Download>? items,
  }) {
    final result = create();
    if (next != null) result.next = next;
    if (items != null) result.items.addAll(items);
    return result;
  }

  DownloadSearchResponse._();

  factory DownloadSearchResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory DownloadSearchResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..aOM<DownloadSearchRequest>(1, _omitFieldNames ? '' : 'next', subBuilder: DownloadSearchRequest.create)
    ..pc<Download>(2, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM, subBuilder: Download.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadSearchResponse clone() => DownloadSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadSearchResponse copyWith(void Function(DownloadSearchResponse) updates) => super.copyWith((message) => updates(message as DownloadSearchResponse)) as DownloadSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadSearchResponse create() => DownloadSearchResponse._();
  @$core.override
  DownloadSearchResponse createEmptyInstance() => create();
  static $pb.PbList<DownloadSearchResponse> createRepeated() => $pb.PbList<DownloadSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static DownloadSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DownloadSearchResponse>(create);
  static DownloadSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DownloadSearchRequest get next => $_getN(0);
  @$pb.TagNumber(1)
  set next(DownloadSearchRequest value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasNext() => $_has(0);
  @$pb.TagNumber(1)
  void clearNext() => $_clearField(1);
  @$pb.TagNumber(1)
  DownloadSearchRequest ensureNext() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<Download> get items => $_getList(1);
}

class DownloadMetadataRequest extends $pb.GeneratedMessage {
  factory DownloadMetadataRequest() => create();

  DownloadMetadataRequest._();

  factory DownloadMetadataRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory DownloadMetadataRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadMetadataRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadMetadataRequest clone() => DownloadMetadataRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadMetadataRequest copyWith(void Function(DownloadMetadataRequest) updates) => super.copyWith((message) => updates(message as DownloadMetadataRequest)) as DownloadMetadataRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadMetadataRequest create() => DownloadMetadataRequest._();
  @$core.override
  DownloadMetadataRequest createEmptyInstance() => create();
  static $pb.PbList<DownloadMetadataRequest> createRepeated() => $pb.PbList<DownloadMetadataRequest>();
  @$core.pragma('dart2js:noInline')
  static DownloadMetadataRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DownloadMetadataRequest>(create);
  static DownloadMetadataRequest? _defaultInstance;
}

class DownloadMetadataResponse extends $pb.GeneratedMessage {
  factory DownloadMetadataResponse({
    Download? download,
  }) {
    final result = create();
    if (download != null) result.download = download;
    return result;
  }

  DownloadMetadataResponse._();

  factory DownloadMetadataResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory DownloadMetadataResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadMetadataResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..aOM<Download>(1, _omitFieldNames ? '' : 'download', subBuilder: Download.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadMetadataResponse clone() => DownloadMetadataResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadMetadataResponse copyWith(void Function(DownloadMetadataResponse) updates) => super.copyWith((message) => updates(message as DownloadMetadataResponse)) as DownloadMetadataResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadMetadataResponse create() => DownloadMetadataResponse._();
  @$core.override
  DownloadMetadataResponse createEmptyInstance() => create();
  static $pb.PbList<DownloadMetadataResponse> createRepeated() => $pb.PbList<DownloadMetadataResponse>();
  @$core.pragma('dart2js:noInline')
  static DownloadMetadataResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DownloadMetadataResponse>(create);
  static DownloadMetadataResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Download get download => $_getN(0);
  @$pb.TagNumber(1)
  set download(Download value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDownload() => $_has(0);
  @$pb.TagNumber(1)
  void clearDownload() => $_clearField(1);
  @$pb.TagNumber(1)
  Download ensureDownload() => $_ensure(0);
}

class DownloadBeginRequest extends $pb.GeneratedMessage {
  factory DownloadBeginRequest() => create();

  DownloadBeginRequest._();

  factory DownloadBeginRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory DownloadBeginRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadBeginRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadBeginRequest clone() => DownloadBeginRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadBeginRequest copyWith(void Function(DownloadBeginRequest) updates) => super.copyWith((message) => updates(message as DownloadBeginRequest)) as DownloadBeginRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadBeginRequest create() => DownloadBeginRequest._();
  @$core.override
  DownloadBeginRequest createEmptyInstance() => create();
  static $pb.PbList<DownloadBeginRequest> createRepeated() => $pb.PbList<DownloadBeginRequest>();
  @$core.pragma('dart2js:noInline')
  static DownloadBeginRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DownloadBeginRequest>(create);
  static DownloadBeginRequest? _defaultInstance;
}

class DownloadBeginResponse extends $pb.GeneratedMessage {
  factory DownloadBeginResponse({
    Download? download,
  }) {
    final result = create();
    if (download != null) result.download = download;
    return result;
  }

  DownloadBeginResponse._();

  factory DownloadBeginResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory DownloadBeginResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadBeginResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..aOM<Download>(1, _omitFieldNames ? '' : 'download', subBuilder: Download.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadBeginResponse clone() => DownloadBeginResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadBeginResponse copyWith(void Function(DownloadBeginResponse) updates) => super.copyWith((message) => updates(message as DownloadBeginResponse)) as DownloadBeginResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadBeginResponse create() => DownloadBeginResponse._();
  @$core.override
  DownloadBeginResponse createEmptyInstance() => create();
  static $pb.PbList<DownloadBeginResponse> createRepeated() => $pb.PbList<DownloadBeginResponse>();
  @$core.pragma('dart2js:noInline')
  static DownloadBeginResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DownloadBeginResponse>(create);
  static DownloadBeginResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Download get download => $_getN(0);
  @$pb.TagNumber(1)
  set download(Download value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDownload() => $_has(0);
  @$pb.TagNumber(1)
  void clearDownload() => $_clearField(1);
  @$pb.TagNumber(1)
  Download ensureDownload() => $_ensure(0);
}

class DownloadPauseRequest extends $pb.GeneratedMessage {
  factory DownloadPauseRequest() => create();

  DownloadPauseRequest._();

  factory DownloadPauseRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory DownloadPauseRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadPauseRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadPauseRequest clone() => DownloadPauseRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadPauseRequest copyWith(void Function(DownloadPauseRequest) updates) => super.copyWith((message) => updates(message as DownloadPauseRequest)) as DownloadPauseRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadPauseRequest create() => DownloadPauseRequest._();
  @$core.override
  DownloadPauseRequest createEmptyInstance() => create();
  static $pb.PbList<DownloadPauseRequest> createRepeated() => $pb.PbList<DownloadPauseRequest>();
  @$core.pragma('dart2js:noInline')
  static DownloadPauseRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DownloadPauseRequest>(create);
  static DownloadPauseRequest? _defaultInstance;
}

class DownloadPauseResponse extends $pb.GeneratedMessage {
  factory DownloadPauseResponse({
    Download? download,
  }) {
    final result = create();
    if (download != null) result.download = download;
    return result;
  }

  DownloadPauseResponse._();

  factory DownloadPauseResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory DownloadPauseResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadPauseResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'media'), createEmptyInstance: create)
    ..aOM<Download>(1, _omitFieldNames ? '' : 'download', subBuilder: Download.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadPauseResponse clone() => DownloadPauseResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadPauseResponse copyWith(void Function(DownloadPauseResponse) updates) => super.copyWith((message) => updates(message as DownloadPauseResponse)) as DownloadPauseResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadPauseResponse create() => DownloadPauseResponse._();
  @$core.override
  DownloadPauseResponse createEmptyInstance() => create();
  static $pb.PbList<DownloadPauseResponse> createRepeated() => $pb.PbList<DownloadPauseResponse>();
  @$core.pragma('dart2js:noInline')
  static DownloadPauseResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DownloadPauseResponse>(create);
  static DownloadPauseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Download get download => $_getN(0);
  @$pb.TagNumber(1)
  set download(Download value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDownload() => $_has(0);
  @$pb.TagNumber(1)
  void clearDownload() => $_clearField(1);
  @$pb.TagNumber(1)
  Download ensureDownload() => $_ensure(0);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
