//
//  Generated code. Do not modify.
//  source: meta.wireguard.proto
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

class Wireguard extends $pb.GeneratedMessage {
  factory Wireguard({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  Wireguard._() : super();
  factory Wireguard.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Wireguard.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Wireguard', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Wireguard clone() => Wireguard()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Wireguard copyWith(void Function(Wireguard) updates) => super.copyWith((message) => updates(message as Wireguard)) as Wireguard;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Wireguard create() => Wireguard._();
  Wireguard createEmptyInstance() => create();
  static $pb.PbList<Wireguard> createRepeated() => $pb.PbList<Wireguard>();
  @$core.pragma('dart2js:noInline')
  static Wireguard getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Wireguard>(create);
  static Wireguard? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class WireguardSearchRequest extends $pb.GeneratedMessage {
  factory WireguardSearchRequest({
    $core.String? query,
    $fixnum.Int64? offset,
    $fixnum.Int64? limit,
    $core.int? status,
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
    if (status != null) {
      $result.status = status;
    }
    return $result;
  }
  WireguardSearchRequest._() : super();
  factory WireguardSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WireguardSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WireguardSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WireguardSearchRequest clone() => WireguardSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WireguardSearchRequest copyWith(void Function(WireguardSearchRequest) updates) => super.copyWith((message) => updates(message as WireguardSearchRequest)) as WireguardSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardSearchRequest create() => WireguardSearchRequest._();
  WireguardSearchRequest createEmptyInstance() => create();
  static $pb.PbList<WireguardSearchRequest> createRepeated() => $pb.PbList<WireguardSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static WireguardSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WireguardSearchRequest>(create);
  static WireguardSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get offset => $_getI64(1);
  @$pb.TagNumber(2)
  set offset($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOffset() => $_has(1);
  @$pb.TagNumber(2)
  void clearOffset() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get limit => $_getI64(2);
  @$pb.TagNumber(3)
  set limit($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get status => $_getIZ(3);
  @$pb.TagNumber(4)
  set status($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);
}

class WireguardSearchResponse extends $pb.GeneratedMessage {
  factory WireguardSearchResponse({
    WireguardSearchRequest? next,
    $core.Iterable<Wireguard>? items,
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
  WireguardSearchResponse._() : super();
  factory WireguardSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WireguardSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WireguardSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..aOM<WireguardSearchRequest>(1, _omitFieldNames ? '' : 'next', subBuilder: WireguardSearchRequest.create)
    ..pc<Wireguard>(2, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM, subBuilder: Wireguard.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WireguardSearchResponse clone() => WireguardSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WireguardSearchResponse copyWith(void Function(WireguardSearchResponse) updates) => super.copyWith((message) => updates(message as WireguardSearchResponse)) as WireguardSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardSearchResponse create() => WireguardSearchResponse._();
  WireguardSearchResponse createEmptyInstance() => create();
  static $pb.PbList<WireguardSearchResponse> createRepeated() => $pb.PbList<WireguardSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static WireguardSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WireguardSearchResponse>(create);
  static WireguardSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  WireguardSearchRequest get next => $_getN(0);
  @$pb.TagNumber(1)
  set next(WireguardSearchRequest v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasNext() => $_has(0);
  @$pb.TagNumber(1)
  void clearNext() => $_clearField(1);
  @$pb.TagNumber(1)
  WireguardSearchRequest ensureNext() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<Wireguard> get items => $_getList(1);
}

class WireguardTouchRequest extends $pb.GeneratedMessage {
  factory WireguardTouchRequest() => create();
  WireguardTouchRequest._() : super();
  factory WireguardTouchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WireguardTouchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WireguardTouchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WireguardTouchRequest clone() => WireguardTouchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WireguardTouchRequest copyWith(void Function(WireguardTouchRequest) updates) => super.copyWith((message) => updates(message as WireguardTouchRequest)) as WireguardTouchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardTouchRequest create() => WireguardTouchRequest._();
  WireguardTouchRequest createEmptyInstance() => create();
  static $pb.PbList<WireguardTouchRequest> createRepeated() => $pb.PbList<WireguardTouchRequest>();
  @$core.pragma('dart2js:noInline')
  static WireguardTouchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WireguardTouchRequest>(create);
  static WireguardTouchRequest? _defaultInstance;
}

class WireguardTouchResponse extends $pb.GeneratedMessage {
  factory WireguardTouchResponse() => create();
  WireguardTouchResponse._() : super();
  factory WireguardTouchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WireguardTouchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WireguardTouchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WireguardTouchResponse clone() => WireguardTouchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WireguardTouchResponse copyWith(void Function(WireguardTouchResponse) updates) => super.copyWith((message) => updates(message as WireguardTouchResponse)) as WireguardTouchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardTouchResponse create() => WireguardTouchResponse._();
  WireguardTouchResponse createEmptyInstance() => create();
  static $pb.PbList<WireguardTouchResponse> createRepeated() => $pb.PbList<WireguardTouchResponse>();
  @$core.pragma('dart2js:noInline')
  static WireguardTouchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WireguardTouchResponse>(create);
  static WireguardTouchResponse? _defaultInstance;
}

class WireguardUploadRequest extends $pb.GeneratedMessage {
  factory WireguardUploadRequest() => create();
  WireguardUploadRequest._() : super();
  factory WireguardUploadRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WireguardUploadRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WireguardUploadRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WireguardUploadRequest clone() => WireguardUploadRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WireguardUploadRequest copyWith(void Function(WireguardUploadRequest) updates) => super.copyWith((message) => updates(message as WireguardUploadRequest)) as WireguardUploadRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardUploadRequest create() => WireguardUploadRequest._();
  WireguardUploadRequest createEmptyInstance() => create();
  static $pb.PbList<WireguardUploadRequest> createRepeated() => $pb.PbList<WireguardUploadRequest>();
  @$core.pragma('dart2js:noInline')
  static WireguardUploadRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WireguardUploadRequest>(create);
  static WireguardUploadRequest? _defaultInstance;
}

class WireguardUploadResponse extends $pb.GeneratedMessage {
  factory WireguardUploadResponse({
    Wireguard? wireguard,
  }) {
    final $result = create();
    if (wireguard != null) {
      $result.wireguard = wireguard;
    }
    return $result;
  }
  WireguardUploadResponse._() : super();
  factory WireguardUploadResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WireguardUploadResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WireguardUploadResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..aOM<Wireguard>(1, _omitFieldNames ? '' : 'wireguard', protoName: 'Wireguard', subBuilder: Wireguard.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WireguardUploadResponse clone() => WireguardUploadResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WireguardUploadResponse copyWith(void Function(WireguardUploadResponse) updates) => super.copyWith((message) => updates(message as WireguardUploadResponse)) as WireguardUploadResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardUploadResponse create() => WireguardUploadResponse._();
  WireguardUploadResponse createEmptyInstance() => create();
  static $pb.PbList<WireguardUploadResponse> createRepeated() => $pb.PbList<WireguardUploadResponse>();
  @$core.pragma('dart2js:noInline')
  static WireguardUploadResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WireguardUploadResponse>(create);
  static WireguardUploadResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Wireguard get wireguard => $_getN(0);
  @$pb.TagNumber(1)
  set wireguard(Wireguard v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasWireguard() => $_has(0);
  @$pb.TagNumber(1)
  void clearWireguard() => $_clearField(1);
  @$pb.TagNumber(1)
  Wireguard ensureWireguard() => $_ensure(0);
}

class WireguardCurrentRequest extends $pb.GeneratedMessage {
  factory WireguardCurrentRequest() => create();
  WireguardCurrentRequest._() : super();
  factory WireguardCurrentRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WireguardCurrentRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WireguardCurrentRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WireguardCurrentRequest clone() => WireguardCurrentRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WireguardCurrentRequest copyWith(void Function(WireguardCurrentRequest) updates) => super.copyWith((message) => updates(message as WireguardCurrentRequest)) as WireguardCurrentRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardCurrentRequest create() => WireguardCurrentRequest._();
  WireguardCurrentRequest createEmptyInstance() => create();
  static $pb.PbList<WireguardCurrentRequest> createRepeated() => $pb.PbList<WireguardCurrentRequest>();
  @$core.pragma('dart2js:noInline')
  static WireguardCurrentRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WireguardCurrentRequest>(create);
  static WireguardCurrentRequest? _defaultInstance;
}

class WireguardCurrentResponse extends $pb.GeneratedMessage {
  factory WireguardCurrentResponse({
    Wireguard? wireguard,
  }) {
    final $result = create();
    if (wireguard != null) {
      $result.wireguard = wireguard;
    }
    return $result;
  }
  WireguardCurrentResponse._() : super();
  factory WireguardCurrentResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WireguardCurrentResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WireguardCurrentResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..aOM<Wireguard>(1, _omitFieldNames ? '' : 'wireguard', protoName: 'Wireguard', subBuilder: Wireguard.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WireguardCurrentResponse clone() => WireguardCurrentResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WireguardCurrentResponse copyWith(void Function(WireguardCurrentResponse) updates) => super.copyWith((message) => updates(message as WireguardCurrentResponse)) as WireguardCurrentResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardCurrentResponse create() => WireguardCurrentResponse._();
  WireguardCurrentResponse createEmptyInstance() => create();
  static $pb.PbList<WireguardCurrentResponse> createRepeated() => $pb.PbList<WireguardCurrentResponse>();
  @$core.pragma('dart2js:noInline')
  static WireguardCurrentResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WireguardCurrentResponse>(create);
  static WireguardCurrentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Wireguard get wireguard => $_getN(0);
  @$pb.TagNumber(1)
  set wireguard(Wireguard v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasWireguard() => $_has(0);
  @$pb.TagNumber(1)
  void clearWireguard() => $_clearField(1);
  @$pb.TagNumber(1)
  Wireguard ensureWireguard() => $_ensure(0);
}

class WireguardDeleteRequest extends $pb.GeneratedMessage {
  factory WireguardDeleteRequest() => create();
  WireguardDeleteRequest._() : super();
  factory WireguardDeleteRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WireguardDeleteRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WireguardDeleteRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WireguardDeleteRequest clone() => WireguardDeleteRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WireguardDeleteRequest copyWith(void Function(WireguardDeleteRequest) updates) => super.copyWith((message) => updates(message as WireguardDeleteRequest)) as WireguardDeleteRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardDeleteRequest create() => WireguardDeleteRequest._();
  WireguardDeleteRequest createEmptyInstance() => create();
  static $pb.PbList<WireguardDeleteRequest> createRepeated() => $pb.PbList<WireguardDeleteRequest>();
  @$core.pragma('dart2js:noInline')
  static WireguardDeleteRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WireguardDeleteRequest>(create);
  static WireguardDeleteRequest? _defaultInstance;
}

class WireguardDeleteResponse extends $pb.GeneratedMessage {
  factory WireguardDeleteResponse({
    Wireguard? wireguard,
  }) {
    final $result = create();
    if (wireguard != null) {
      $result.wireguard = wireguard;
    }
    return $result;
  }
  WireguardDeleteResponse._() : super();
  factory WireguardDeleteResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WireguardDeleteResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WireguardDeleteResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'), createEmptyInstance: create)
    ..aOM<Wireguard>(1, _omitFieldNames ? '' : 'wireguard', protoName: 'Wireguard', subBuilder: Wireguard.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WireguardDeleteResponse clone() => WireguardDeleteResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WireguardDeleteResponse copyWith(void Function(WireguardDeleteResponse) updates) => super.copyWith((message) => updates(message as WireguardDeleteResponse)) as WireguardDeleteResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardDeleteResponse create() => WireguardDeleteResponse._();
  WireguardDeleteResponse createEmptyInstance() => create();
  static $pb.PbList<WireguardDeleteResponse> createRepeated() => $pb.PbList<WireguardDeleteResponse>();
  @$core.pragma('dart2js:noInline')
  static WireguardDeleteResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WireguardDeleteResponse>(create);
  static WireguardDeleteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Wireguard get wireguard => $_getN(0);
  @$pb.TagNumber(1)
  set wireguard(Wireguard v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasWireguard() => $_has(0);
  @$pb.TagNumber(1)
  void clearWireguard() => $_clearField(1);
  @$pb.TagNumber(1)
  Wireguard ensureWireguard() => $_ensure(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
