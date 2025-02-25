import 'dart:collection';

import 'package:rive/src/rive_core/runtime/exceptions/rive_format_error_exception.dart';

export 'package:rive/src/animation_list.dart';
export 'package:rive/src/state_machine_components.dart';
export 'package:rive/src/state_transition_conditions.dart';
export 'package:rive/src/state_transitions.dart';
export 'package:rive/src/container_children.dart';
export 'package:rive/src/runtime_artboard.dart';
export 'package:rive/src/generated/rive_core_context.dart';
export 'package:rive/src/core/importers/artboard_importer.dart';
export 'package:rive/src/core/importers/linear_animation_importer.dart';
export 'package:rive/src/core/importers/keyed_object_importer.dart';
export 'package:rive/src/core/importers/keyed_property_importer.dart';
export 'package:rive/src/core/importers/state_machine_importer.dart';
export 'package:rive/src/core/importers/state_machine_layer_importer.dart';
export 'package:rive/src/core/importers/layer_state_importer.dart';
export 'package:rive/src/core/importers/state_transition_importer.dart';

typedef PropertyChangeCallback = void Function(dynamic from, dynamic to);
typedef BatchAddCallback = void Function();

abstract class Core<T extends CoreContext> {
  static const int missingId = -1;
  covariant late T context;
  int get coreType;
  int id = missingId;
  Set<int> get coreTypes => {};
  bool _hasValidated = false;
  bool get hasValidated => _hasValidated;

  void onAddedDirty();
  void onAdded() {}
  void onRemoved() {}
  void remove() => context.removeObject(this);
  bool import(ImportStack stack) => true;

  bool validate() => true;
}

class InternalCoreHelper {
  static void markValid(Core object) {
    object._hasValidated = true;
  }
}

abstract class CoreContext {
  static const int invalidPropertyKey = 0;

  Core? makeCoreInstance(int typeKey);
  T? resolve<T>(int id);
  T resolveWithDefault<T>(int id, T defaultValue);
  void markDependencyOrderDirty();
  bool markDependenciesDirty(covariant Core rootObject);
  void removeObject<T extends Core>(T object);
  T? addObject<T extends Core>(T? object);
  void markNeedsAdvance();
  void dirty(void Function() dirt);
}

// ignore: one_member_abstracts
abstract class ImportStackObject {
  bool resolve();
}

/// Stack to help the RiveFile locate latest ImportStackObject created of a
/// certain type.
class ImportStack {
  final _latests = HashMap<int, ImportStackObject>();
  T? latest<T extends ImportStackObject>(int coreType) {
    var latest = _latests[coreType];
    if (latest is T) {
      return latest;
    }
    return null;
  }

  T requireLatest<T extends ImportStackObject>(int coreType) {
    var object = latest<T>(coreType);
    if (object == null) {
      throw RiveFormatErrorException(
          'Rive file is corrupt. Couldn\'t find expected object of type '
          '$coreType in import stack.');
    }
    return object;
  }

  bool makeLatest(int coreType, ImportStackObject? importObject) {
    var latest = _latests[coreType];
    if (latest != null) {
      if (!latest.resolve()) {
        return false;
      }
    }
    if (importObject != null) {
      _latests[coreType] = importObject;
    } else {
      _latests.remove(coreType);
    }
    return true;
  }

  bool resolve() {
    for (final object in _latests.values) {
      if (!object.resolve()) {
        return false;
      }
    }
    return true;
  }
}
