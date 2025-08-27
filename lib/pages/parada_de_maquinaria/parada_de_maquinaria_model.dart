import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'parada_de_maquinaria_widget.dart' show ParadaDeMaquinariaWidget;
import 'package:flutter/material.dart';

class ParadaDeMaquinariaModel
    extends FlutterFlowModel<ParadaDeMaquinariaWidget> {
  ///  Local state fields for this page.

  String dropdownParada = '\"\"';

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for CheckboxListTil widget.
  bool? checkboxListTilValue;
  // State field(s) for CheckboxListTile widget.
  bool? checkboxListTileValue1;
  // State field(s) for CheckboxListTile widget.
  bool? checkboxListTileValue2;
  // State field(s) for CheckboxListTile widget.
  bool? checkboxListTileValue3;
  // State field(s) for CheckboxListTileMantenimiento widget.
  bool? checkboxListTileMantenimientoValue;
  // State field(s) for CheckboxListTile widget.
  bool? checkboxListTileValue4;
  // State field(s) for CheckboxListTileOtros widget.
  bool? checkboxListTileOtrosValue;
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
