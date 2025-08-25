import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'registro_mantenimiento_widget.dart' show RegistroMantenimientoWidget;
import 'package:flutter/material.dart';

class RegistroMantenimientoModel
    extends FlutterFlowModel<RegistroMantenimientoWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for TextFieldCode widget.
  final textFieldCodeKey = GlobalKey();
  FocusNode? textFieldCodeFocusNode;
  TextEditingController? textFieldCodeTextController;
  String? textFieldCodeSelectedOption;
  String? Function(BuildContext, String?)? textFieldCodeTextControllerValidator;
  // State field(s) for TextFieldEquipo widget.
  final textFieldEquipoKey = GlobalKey();
  FocusNode? textFieldEquipoFocusNode;
  TextEditingController? textFieldEquipoTextController;
  String? textFieldEquipoSelectedOption;
  String? Function(BuildContext, String?)?
      textFieldEquipoTextControllerValidator;
  // State field(s) for DropDown widget.
  String? dropDownValue1;
  FormFieldController<String>? dropDownValueController1;
  // State field(s) for DropDown widget.
  String? dropDownValue2;
  FormFieldController<String>? dropDownValueController2;
  // State field(s) for DropDown widget.
  String? dropDownValue3;
  FormFieldController<String>? dropDownValueController3;
  // State field(s) for TextFieldDate widget.
  FocusNode? textFieldDateFocusNode;
  TextEditingController? textFieldDateTextController;
  String? Function(BuildContext, String?)? textFieldDateTextControllerValidator;
  // State field(s) for DropDown widget.
  String? dropDownValue4;
  FormFieldController<String>? dropDownValueController4;
  // State field(s) for DropDown widget.
  String? dropDownValue5;
  FormFieldController<String>? dropDownValueController5;
  // State field(s) for DropDown widget.
  String? dropDownValue6;
  FormFieldController<String>? dropDownValueController6;
  // State field(s) for DropDown widget.
  String? dropDownValue7;
  FormFieldController<String>? dropDownValueController7;
  // State field(s) for DropDown widget.
  String? dropDownValue8;
  FormFieldController<String>? dropDownValueController8;
  // State field(s) for DropDown widget.
  String? dropDownValue9;
  FormFieldController<String>? dropDownValueController9;
  // State field(s) for DropDown widget.
  String? dropDownValue10;
  FormFieldController<String>? dropDownValueController10;
  // State field(s) for DropDown widget.
  String? dropDownValue11;
  FormFieldController<String>? dropDownValueController11;
  // State field(s) for DropDown widget.
  String? dropDownValue12;
  FormFieldController<String>? dropDownValueController12;
  // State field(s) for DropDown widget.
  String? dropDownValue13;
  FormFieldController<String>? dropDownValueController13;
  // State field(s) for DropDown widget.
  String? dropDownValue14;
  FormFieldController<String>? dropDownValueController14;
  // State field(s) for DropDown widget.
  String? dropDownValue15;
  FormFieldController<String>? dropDownValueController15;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldCodeFocusNode?.dispose();

    textFieldEquipoFocusNode?.dispose();

    textFieldDateFocusNode?.dispose();
    textFieldDateTextController?.dispose();
  }
}
