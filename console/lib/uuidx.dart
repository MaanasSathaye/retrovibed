import 'package:uuid/uuid.dart' as uuid;

uuid.UuidValue fromString(String v) => uuid.UuidValue.fromString(v);

String max() => uuid.Namespace.max.value;
String min() => uuid.Namespace.nil.value;

bool isMin(uuid.UuidValue v) => v == uuid.Namespace.nil.uuidValue;
bool isMax(uuid.UuidValue v) => v == uuid.Namespace.max.uuidValue;
bool isMinMax(uuid.UuidValue v) => isMin(v) || isMax(v);