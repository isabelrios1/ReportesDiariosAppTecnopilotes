import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'parada_de_maquinaria_widget.dart' show ParadaDeMaquinariaWidget;
import 'package:flutter/material.dart';

class ParadaDeMaquinariaModel
    extends FlutterFlowModel<ParadaDeMaquinariaWidget> {
  ///  Local state fields for this page.

  bool chkFallaMecanica = false;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for CheckboxListTile widget.
  bool? checkboxListTileValue1;
  // State field(s) for CheckboxListTile widget.
  bool? checkboxListTileValue2;
  // State field(s) for CheckboxListTile widget.
  bool? checkboxListTileValue3;
  // State field(s) for CheckboxListTile widget.
  bool? checkboxListTileValue4;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // State field(s) for CheckboxListTile widget.
  bool? checkboxListTileValue5;
  // State field(s) for CheckboxListTile widget.
  bool? checkboxListTileValue6;
  // State field(s) for TextFieldOtros widget.
  FocusNode? textFieldOtrosFocusNode;
  TextEditingController? textFieldOtrosTextController;
  String? Function(BuildContext, String?)?
      textFieldOtrosTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldOtrosFocusNode?.dispose();
    textFieldOtrosTextController?.dispose();
  }
}
