import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'nuevo_registro_diario_widget.dart' show NuevoRegistroDiarioWidget;
import 'package:flutter/material.dart';

class NuevoRegistroDiarioModel
    extends FlutterFlowModel<NuevoRegistroDiarioWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for TextFieldDate widget.
  FocusNode? textFieldDateFocusNode;
  TextEditingController? textFieldDateTextController;
  String? Function(BuildContext, String?)? textFieldDateTextControllerValidator;
  // State field(s) for DropDown widget.
  String? dropDownValue1;
  FormFieldController<String>? dropDownValueController1;
  // State field(s) for RadioButtonTurno widget.
  FormFieldController<String>? radioButtonTurnoValueController;
  // State field(s) for DropDown widget.
  String? dropDownValue2;
  FormFieldController<String>? dropDownValueController2;
  // State field(s) for TextFieldCode widget.
  final textFieldCodeKey = GlobalKey();
  FocusNode? textFieldCodeFocusNode;
  TextEditingController? textFieldCodeTextController;
  String? textFieldCodeSelectedOption;
  String? Function(BuildContext, String?)? textFieldCodeTextControllerValidator;
  // State field(s) for TextFieldMachineName widget.
  final textFieldMachineNameKey = GlobalKey();
  FocusNode? textFieldMachineNameFocusNode;
  TextEditingController? textFieldMachineNameTextController;
  String? textFieldMachineNameSelectedOption;
  String? Function(BuildContext, String?)?
      textFieldMachineNameTextControllerValidator;
  // State field(s) for DropDown widget.
  String? dropDownValue3;
  FormFieldController<String>? dropDownValueController3;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldDateFocusNode?.dispose();
    textFieldDateTextController?.dispose();

    textFieldCodeFocusNode?.dispose();

    textFieldMachineNameFocusNode?.dispose();
  }

  /// Additional helper methods.
  String? get radioButtonTurnoValue => radioButtonTurnoValueController?.value;
}
