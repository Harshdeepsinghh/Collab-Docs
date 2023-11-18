import 'package:collabDocs/api/appApi.dart';
import 'package:collabDocs/constants/appColors.dart';
import 'package:collabDocs/providers/myProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetPasswordScreen extends ConsumerStatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangePassWordScreenState();
}

class _ChangePassWordScreenState extends ConsumerState<SetPasswordScreen> {
  TextEditingController _newPassword = TextEditingController();
  TextEditingController _repeatPassword = TextEditingController();
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _globalKey,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Change Password",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 40),
              kRepeatedTextFieldAndHead(context,
                  label: "New password",
                  controller: _newPassword, validator: (val) {
                if (val!.split("").length < 6) {
                  return "Please write a valid password";
                }
                return null;
              }, isPassword: true),
              kRepeatedTextFieldAndHead(context,
                  label: "Repeat new password",
                  controller: _repeatPassword, validator: (val) {
                if (val == '') {
                  return "Please write a valid password";
                } else if (val != _newPassword.text) {
                  return "Password does not match";
                }
                return null;
              }, isPassword: false),
              InkWell(
                onTap: () async {
                  if (_globalKey.currentState!.validate()) {
                    await AppApi().changePassword(context,
                        oldPassword: '', newPassword: _newPassword.text);
                  }
                },
                child: Container(
                  margin: EdgeInsets.all(10),
                  width: 280,
                  height: 40,
                  color: kPrimaryColor(),
                  child: Center(child: Text("save")),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Column kRepeatedTextFieldAndHead(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    required bool isPassword,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: ref.read(themeProvider) ? kWhiteColor() : kGreyColor()),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          child: TextFormField(
            obscureText: isPassword,
            controller: controller,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              isDense: true,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: kGreyColor(), width: 0.5)),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
