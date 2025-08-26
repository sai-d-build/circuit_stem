abstract class ComponentAction {
  const ComponentAction();
}

class CreateComponentFromTemplateAction extends ComponentAction {
  final String templateId;
  final int row;
  final int col;

  const CreateComponentFromTemplateAction({
    required this.templateId,
    required this.row,
    required this.col,
  });
}

class MoveComponentAction extends ComponentAction {
  final String componentId;
  final int newRow;
  final int newCol;

  const MoveComponentAction({
    required this.componentId,
    required this.newRow,
    required this.newCol,
  });
}

class TapComponentAction extends ComponentAction {
  final String componentId;

  const TapComponentAction({
    required this.componentId,
  });
}

class RotateComponentAction extends ComponentAction {
  final String componentId;
  final int rotation;

  const RotateComponentAction({
    required this.componentId,
    required this.rotation,
  });
}

class RestartLevelAction extends ComponentAction {
  const RestartLevelAction();
}

class UpdateComponentAction extends ComponentAction {
  final String componentId;
  final Map<String, dynamic> newState;

  const UpdateComponentAction({
    required this.componentId,
    required this.newState,
  });
}

class SelectPaletteComponentAction extends ComponentAction {
  final String componentId;

  const SelectPaletteComponentAction({
    required this.componentId,
  });
}
