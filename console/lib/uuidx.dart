import 'package:uuid/uuid.dart' as uuid;

uuid.UuidValue fromString(String v) => uuid.UuidValue.fromString(v);

bool isMin(uuid.UuidValue v) => v == uuid.Namespace.nil.uuidValue;
bool IsMax(uuid.UuidValue v) => v == uuid.Namespace.max.uuidValue;