import 'package:rive/src/core/core.dart';
import 'package:rive/src/rive_core/animation/state_transition.dart';
import 'package:rive/src/rive_core/animation/transition_condition.dart';

class StateTransitionImporter extends ImportStackObject {
  final StateMachineImporter stateMachineImporter;
  final StateTransition transition;
  StateTransitionImporter(this.transition, this.stateMachineImporter);

  void addCondition(TransitionCondition condition) {
    transition.context.addObject(condition);
    transition.internalAddCondition(condition);
  }

  @override
  bool resolve() {
    var inputs = stateMachineImporter.machine.inputs;
    for (final condition in transition.conditions) {
      var inputIndex = condition.inputId;
      assert(inputIndex >= 0 && inputIndex < inputs.length);
      condition.inputId = inputs[inputIndex].id;
    }
    return true;
  }
}
