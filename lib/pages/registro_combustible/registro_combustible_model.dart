import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'registro_combustible_widget.dart' show RegistroCombustibleWidget;
import 'package:flutter/material.dart';

class RegistroCombustibleModel
    extends FlutterFlowModel<RegistroCombustibleWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for TextFieldCode widget.
  final textFieldCodeKey1 = GlobalKey();
  FocusNode? textFieldCodeFocusNode1;
  TextEditingController? textFieldCodeTextController1;
  String? textFieldCodeSelectedOption1;
  String? Function(BuildContext, String?)?
      textFieldCodeTextController1Validator;
  // State field(s) for TextFieldEquipo widget.
  final textFieldEquipoKey = GlobalKey();
  FocusNode? textFieldEquipoFocusNode;
  TextEditingController? textFieldEquipoTextController;
  String? textFieldEquipoSelectedOption;
  String? Function(BuildContext, String?)?
      textFieldEquipoTextControllerValidator;
  // State field(s) for TextFieldDate widget.
  FocusNode? textFieldDateFocusNode;
  TextEditingController? textFieldDateTextController;
  String? Function(BuildContext, String?)? textFieldDateTextControllerValidator;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // State field(s) for TextFieldCode widget.
  final textFieldCodeKey2 = GlobalKey();
  FocusNode? textFieldCodeFocusNode2;
  TextEditingController? textFieldCodeTextController2;
  String? textFieldCodeSelectedOption2;
  String? Function(BuildContext, String?)?
      textFieldCodeTextController2Validator;
  // State field(s) for TextFieldCode widget.
  final textFieldCodeKey3 = GlobalKey();
  FocusNode? textFieldCodeFocusNode3;
  TextEditingController? textFieldCodeTextController3;
  String? textFieldCodeSelectedOption3;
  String? Function(BuildContext, String?)?
      textFieldCodeTextController3Validator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldCodeFocusNode1?.dispose();

    textFieldEquipoFocusNode?.dispose();

    textFieldDateFocusNode?.dispose();
    textFieldDateTextController?.dispose();

    textFieldCodeFocusNode2?.dispose();

    textFieldCodeFocusNode3?.dispose();
  }
}
