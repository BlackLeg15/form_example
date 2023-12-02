import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController passwordController;
  late final GlobalKey<FormState> formKey;
  late final MaskTextInputFormatter phoneMask;
  late bool showPassword;

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController();
    nameController = TextEditingController();
    addressController = TextEditingController();
    passwordController = TextEditingController();
    formKey = GlobalKey<FormState>();
    phoneMask = MaskTextInputFormatter(
      mask: '(##) # ####-####',
      filter: {
        '#': RegExp(r'[0-9]'),
      },
    );
    showPassword = false;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    addressController.dispose();
    super.dispose();
  }

  String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome vazio';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha vazia';
    }
    if (value.length < 6) {
      return 'Senha curta';
    }
    return null;
  }

  String? addressValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Endereço vazio';
    }
    return null;
  }

  String? phoneValidator(String? value) {
    final unmaskedValue = phoneMask.getUnmaskedText();
    if (unmaskedValue.isEmpty) {
      return 'Telefone vazio';
    }
    if (unmaskedValue.length < 11) {
      return 'Telefone inválido';
    }
    return null;
  }

  void hideShowPassword() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  void clearAllFields() {
    nameController.clear();
    passwordController.clear();
    addressController.clear();
    phoneController.clear();
    phoneMask.clear();
    formKey.currentState?.reset();
  }

  void validateForm() {
    final isValid = formKey.currentState?.validate() ?? false;
    final message = isValid ? 'Formulário válido' : 'Formulário inválido';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        final result = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: const Text('Tem certeza que deseja sair?\nVocê perderá todos os dados digitados.'),
                icon: const Icon(
                  Icons.warning,
                  color: Colors.deepPurple,
                  size: 50,
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('Não'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Sim'),
                  ),
                ],
              );
            });
        if (result ?? false) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Formulário'),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 60,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  TextFormField(
                    controller: nameController,
                    validator: nameValidator,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      label: Text('Nome'),
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 20,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    obscureText: !showPassword,
                    validator: passwordValidator,
                    controller: passwordController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      label: const Text('Senha'),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: hideShowPassword,
                        icon: Stack(
                          children: [
                            const Icon(Icons.remove_red_eye),
                            if (showPassword) const Icon(Icons.remove),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressController,
                    validator: addressValidator,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      label: Text('Endereço'),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    validator: phoneValidator,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      label: Text('Telefone'),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [phoneMask],
                  ),
                ],
              ),
            ),
          ),
        ),
        persistentFooterAlignment: AlignmentDirectional.center,
        persistentFooterButtons: [
          ElevatedButton(
            onPressed: validateForm,
            child: const Text('Validar'),
          ),
          ElevatedButton(
            onPressed: clearAllFields,
            child: const Text('Limpar tudo'),
          ),
        ],
      ),
    );
  }
}
