import 'package:flutter/material.dart';
import 'package:flutter_app/controller/main_controller.dart';
import 'package:get/get.dart';

class FormInputAuth extends StatelessWidget {
  const FormInputAuth({
    super.key,
    required this.emailCtrl,
    required this.passCtrl,
    this.confirmPassCtrl,
    this.onPressed,
  });

  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController? confirmPassCtrl;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'str_title_login'.tr,
          style: Get.textTheme.displayLarge,
        ),
        TextFormField(
          controller: emailCtrl,
          decoration: InputDecoration(
            hintText: 'user_name'.tr,
            hintStyle: Get.textTheme.bodyMedium
                ?.apply(color: Get.theme.colorScheme.outline),
          ),
        ),
        TextFormField(
          controller: passCtrl,
          decoration: InputDecoration(
            hintText: 'pass_word'.tr,
            hintStyle: Get.textTheme.bodyMedium
                ?.apply(color: Get.theme.colorScheme.outline),
          ),
          obscureText: true,
        ),
        if (confirmPassCtrl != null)
          TextFormField(
            controller: confirmPassCtrl,
            decoration: InputDecoration(
              hintText: 'confirm_pass_word'.tr,
              hintStyle: Get.textTheme.bodyMedium
                  ?.apply(color: Get.theme.colorScheme.outline),
            ),
            obscureText: true,
          ),
        const SizedBox(
          height: 24,
        ),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Get.theme.primaryColorDark,
          ),
          child: GetX<MainController>(
            builder: (ctrl) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (ctrl.isFetching.value == true)
                    Container(
                      height: 20,
                      width: 20,
                      margin: const EdgeInsets.only(right: 6),
                      child: CircularProgressIndicator(
                        color: Get.theme.colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    ),
                  Text(
                    (confirmPassCtrl == null)
                        ? 'str_btn_login'.tr
                        : 'str_btn_sign_up'.tr,
                    style: Get.textTheme.labelMedium
                        ?.apply(color: Get.theme.colorScheme.background),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
