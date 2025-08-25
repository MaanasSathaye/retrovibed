import 'package:uuid/uuid.dart' as uuid;

uuid.UuidValue fromString(String v) => uuid.UuidValue.fromString(v);

bool isMin(uuid.UuidValue v) => v == uuid.Namespace.nil.uuidValue;
bool isMax(uuid.UuidValue v) => v == uuid.Namespace.max.uuidValue;
bool isMinMax(uuid.UuidValue v) => isMin(v) || isMax(v);