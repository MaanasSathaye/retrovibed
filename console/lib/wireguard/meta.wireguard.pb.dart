// This is a generated file - do not edit.
//
// Generated from meta.wireguard.proto.

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

class Wireguard extends $pb.GeneratedMessage {
  factory Wireguard({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  Wireguard._();

  factory Wireguard.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Wireguard.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Wireguard',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Wireguard clone() => Wireguard()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Wireguard copyWith(void Function(Wireguard) updates) =>
      super.copyWith((message) => updates(message as Wireguard)) as Wireguard;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Wireguard create() => Wireguard._();
  @$core.override
  Wireguard createEmptyInstance() => create();
  static $pb.PbList<Wireguard> createRepeated() => $pb.PbList<Wireguard>();
  @$core.pragma('dart2js:noInline')
  static Wireguard getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Wireguard>(create);
  static Wireguard? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
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
    final result = create();
    if (query != null) result.query = query;
    if (offset != null) result.offset = offset;
    if (limit != null) result.limit = limit;
    if (status != null) result.status = status;
    return result;
  }

  WireguardSearchRequest._();

  factory WireguardSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WireguardSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WireguardSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardSearchRequest clone() =>
      WireguardSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardSearchRequest copyWith(
          void Function(WireguardSearchRequest) updates) =>
      super.copyWith((message) => updates(message as WireguardSearchRequest))
          as WireguardSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardSearchRequest create() => WireguardSearchRequest._();
  @$core.override
  WireguardSearchRequest createEmptyInstance() => create();
  static $pb.PbList<WireguardSearchRequest> createRepeated() =>
      $pb.PbList<WireguardSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static WireguardSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WireguardSearchRequest>(create);
  static WireguardSearchRequest? _defaultInstance;

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

  @$pb.TagNumber(4)
  $core.int get status => $_getIZ(3);
  @$pb.TagNumber(4)
  set status($core.int value) => $_setUnsignedInt32(3, value);
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
    final result = create();
    if (next != null) result.next = next;
    if (items != null) result.items.addAll(items);
    return result;
  }

  WireguardSearchResponse._();

  factory WireguardSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WireguardSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WireguardSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'),
      createEmptyInstance: create)
    ..aOM<WireguardSearchRequest>(1, _omitFieldNames ? '' : 'next',
        subBuilder: WireguardSearchRequest.create)
    ..pc<Wireguard>(2, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM,
        subBuilder: Wireguard.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardSearchResponse clone() =>
      WireguardSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardSearchResponse copyWith(
          void Function(WireguardSearchResponse) updates) =>
      super.copyWith((message) => updates(message as WireguardSearchResponse))
          as WireguardSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardSearchResponse create() => WireguardSearchResponse._();
  @$core.override
  WireguardSearchResponse createEmptyInstance() => create();
  static $pb.PbList<WireguardSearchResponse> createRepeated() =>
      $pb.PbList<WireguardSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static WireguardSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WireguardSearchResponse>(create);
  static WireguardSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  WireguardSearchRequest get next => $_getN(0);
  @$pb.TagNumber(1)
  set next(WireguardSearchRequest value) => $_setField(1, value);
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

  WireguardTouchRequest._();

  factory WireguardTouchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WireguardTouchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WireguardTouchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardTouchRequest clone() =>
      WireguardTouchRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardTouchRequest copyWith(
          void Function(WireguardTouchRequest) updates) =>
      super.copyWith((message) => updates(message as WireguardTouchRequest))
          as WireguardTouchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardTouchRequest create() => WireguardTouchRequest._();
  @$core.override
  WireguardTouchRequest createEmptyInstance() => create();
  static $pb.PbList<WireguardTouchRequest> createRepeated() =>
      $pb.PbList<WireguardTouchRequest>();
  @$core.pragma('dart2js:noInline')
  static WireguardTouchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WireguardTouchRequest>(create);
  static WireguardTouchRequest? _defaultInstance;
}

class WireguardTouchResponse extends $pb.GeneratedMessage {
  factory WireguardTouchResponse() => create();

  WireguardTouchResponse._();

  factory WireguardTouchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WireguardTouchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WireguardTouchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardTouchResponse clone() =>
      WireguardTouchResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardTouchResponse copyWith(
          void Function(WireguardTouchResponse) updates) =>
      super.copyWith((message) => updates(message as WireguardTouchResponse))
          as WireguardTouchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardTouchResponse create() => WireguardTouchResponse._();
  @$core.override
  WireguardTouchResponse createEmptyInstance() => create();
  static $pb.PbList<WireguardTouchResponse> createRepeated() =>
      $pb.PbList<WireguardTouchResponse>();
  @$core.pragma('dart2js:noInline')
  static WireguardTouchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WireguardTouchResponse>(create);
  static WireguardTouchResponse? _defaultInstance;
}

class WireguardUploadRequest extends $pb.GeneratedMessage {
  factory WireguardUploadRequest() => create();

  WireguardUploadRequest._();

  factory WireguardUploadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WireguardUploadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WireguardUploadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardUploadRequest clone() =>
      WireguardUploadRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardUploadRequest copyWith(
          void Function(WireguardUploadRequest) updates) =>
      super.copyWith((message) => updates(message as WireguardUploadRequest))
          as WireguardUploadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardUploadRequest create() => WireguardUploadRequest._();
  @$core.override
  WireguardUploadRequest createEmptyInstance() => create();
  static $pb.PbList<WireguardUploadRequest> createRepeated() =>
      $pb.PbList<WireguardUploadRequest>();
  @$core.pragma('dart2js:noInline')
  static WireguardUploadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WireguardUploadRequest>(create);
  static WireguardUploadRequest? _defaultInstance;
}

class WireguardUploadResponse extends $pb.GeneratedMessage {
  factory WireguardUploadResponse({
    Wireguard? wireguard,
  }) {
    final result = create();
    if (wireguard != null) result.wireguard = wireguard;
    return result;
  }

  WireguardUploadResponse._();

  factory WireguardUploadResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WireguardUploadResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WireguardUploadResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'),
      createEmptyInstance: create)
    ..aOM<Wireguard>(1, _omitFieldNames ? '' : 'wireguard',
        protoName: 'Wireguard', subBuilder: Wireguard.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardUploadResponse clone() =>
      WireguardUploadResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardUploadResponse copyWith(
          void Function(WireguardUploadResponse) updates) =>
      super.copyWith((message) => updates(message as WireguardUploadResponse))
          as WireguardUploadResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardUploadResponse create() => WireguardUploadResponse._();
  @$core.override
  WireguardUploadResponse createEmptyInstance() => create();
  static $pb.PbList<WireguardUploadResponse> createRepeated() =>
      $pb.PbList<WireguardUploadResponse>();
  @$core.pragma('dart2js:noInline')
  static WireguardUploadResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WireguardUploadResponse>(create);
  static WireguardUploadResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Wireguard get wireguard => $_getN(0);
  @$pb.TagNumber(1)
  set wireguard(Wireguard value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasWireguard() => $_has(0);
  @$pb.TagNumber(1)
  void clearWireguard() => $_clearField(1);
  @$pb.TagNumber(1)
  Wireguard ensureWireguard() => $_ensure(0);
}

class WireguardCurrentRequest extends $pb.GeneratedMessage {
  factory WireguardCurrentRequest() => create();

  WireguardCurrentRequest._();

  factory WireguardCurrentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WireguardCurrentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WireguardCurrentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardCurrentRequest clone() =>
      WireguardCurrentRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardCurrentRequest copyWith(
          void Function(WireguardCurrentRequest) updates) =>
      super.copyWith((message) => updates(message as WireguardCurrentRequest))
          as WireguardCurrentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardCurrentRequest create() => WireguardCurrentRequest._();
  @$core.override
  WireguardCurrentRequest createEmptyInstance() => create();
  static $pb.PbList<WireguardCurrentRequest> createRepeated() =>
      $pb.PbList<WireguardCurrentRequest>();
  @$core.pragma('dart2js:noInline')
  static WireguardCurrentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WireguardCurrentRequest>(create);
  static WireguardCurrentRequest? _defaultInstance;
}

class WireguardCurrentResponse extends $pb.GeneratedMessage {
  factory WireguardCurrentResponse({
    Wireguard? wireguard,
  }) {
    final result = create();
    if (wireguard != null) result.wireguard = wireguard;
    return result;
  }

  WireguardCurrentResponse._();

  factory WireguardCurrentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WireguardCurrentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WireguardCurrentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'),
      createEmptyInstance: create)
    ..aOM<Wireguard>(1, _omitFieldNames ? '' : 'wireguard',
        protoName: 'Wireguard', subBuilder: Wireguard.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardCurrentResponse clone() =>
      WireguardCurrentResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardCurrentResponse copyWith(
          void Function(WireguardCurrentResponse) updates) =>
      super.copyWith((message) => updates(message as WireguardCurrentResponse))
          as WireguardCurrentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardCurrentResponse create() => WireguardCurrentResponse._();
  @$core.override
  WireguardCurrentResponse createEmptyInstance() => create();
  static $pb.PbList<WireguardCurrentResponse> createRepeated() =>
      $pb.PbList<WireguardCurrentResponse>();
  @$core.pragma('dart2js:noInline')
  static WireguardCurrentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WireguardCurrentResponse>(create);
  static WireguardCurrentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Wireguard get wireguard => $_getN(0);
  @$pb.TagNumber(1)
  set wireguard(Wireguard value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasWireguard() => $_has(0);
  @$pb.TagNumber(1)
  void clearWireguard() => $_clearField(1);
  @$pb.TagNumber(1)
  Wireguard ensureWireguard() => $_ensure(0);
}

class WireguardDeleteRequest extends $pb.GeneratedMessage {
  factory WireguardDeleteRequest() => create();

  WireguardDeleteRequest._();

  factory WireguardDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WireguardDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WireguardDeleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardDeleteRequest clone() =>
      WireguardDeleteRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardDeleteRequest copyWith(
          void Function(WireguardDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as WireguardDeleteRequest))
          as WireguardDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardDeleteRequest create() => WireguardDeleteRequest._();
  @$core.override
  WireguardDeleteRequest createEmptyInstance() => create();
  static $pb.PbList<WireguardDeleteRequest> createRepeated() =>
      $pb.PbList<WireguardDeleteRequest>();
  @$core.pragma('dart2js:noInline')
  static WireguardDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WireguardDeleteRequest>(create);
  static WireguardDeleteRequest? _defaultInstance;
}

class WireguardDeleteResponse extends $pb.GeneratedMessage {
  factory WireguardDeleteResponse({
    Wireguard? wireguard,
  }) {
    final result = create();
    if (wireguard != null) result.wireguard = wireguard;
    return result;
  }

  WireguardDeleteResponse._();

  factory WireguardDeleteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WireguardDeleteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WireguardDeleteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meta'),
      createEmptyInstance: create)
    ..aOM<Wireguard>(1, _omitFieldNames ? '' : 'wireguard',
        protoName: 'Wireguard', subBuilder: Wireguard.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardDeleteResponse clone() =>
      WireguardDeleteResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WireguardDeleteResponse copyWith(
          void Function(WireguardDeleteResponse) updates) =>
      super.copyWith((message) => updates(message as WireguardDeleteResponse))
          as WireguardDeleteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WireguardDeleteResponse create() => WireguardDeleteResponse._();
  @$core.override
  WireguardDeleteResponse createEmptyInstance() => create();
  static $pb.PbList<WireguardDeleteResponse> createRepeated() =>
      $pb.PbList<WireguardDeleteResponse>();
  @$core.pragma('dart2js:noInline')
  static WireguardDeleteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WireguardDeleteResponse>(create);
  static WireguardDeleteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Wireguard get wireguard => $_getN(0);
  @$pb.TagNumber(1)
  set wireguard(Wireguard value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasWireguard() => $_has(0);
  @$pb.TagNumber(1)
  void clearWireguard() => $_clearField(1);
  @$pb.TagNumber(1)
  Wireguard ensureWireguard() => $_ensure(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
