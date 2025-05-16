import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecinema_desktop/models/discount.dart';
import 'package:ecinema_desktop/providers/discount_provider.dart';
import 'package:flutter/services.dart';

class DiscountFormScreen extends StatefulWidget {
  final Discount? discount;

  const DiscountFormScreen({super.key, this.discount});

  @override
  State<DiscountFormScreen> createState() => _DiscountFormScreenState();
}

class _DiscountFormScreenState extends State<DiscountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _discountPercentageController = TextEditingController();

  final _discountProvider = DiscountProvider();

  DateTime? _validFrom;
  DateTime? _validTo;
  bool _isActive = true;

  bool get isEditMode => widget.discount != null;

  @override
  void initState() {
    super.initState();
    if (widget.discount != null) {
      final d = widget.discount!;
      _codeController.text = d.code;
      _discountPercentageController.text = d.discountPercentage.toString();
      _validFrom = d.validFrom;
      _validTo = d.validTo;
      _isActive = d.isActive;
    } else {
      _validFrom = DateTime.now();

      _validTo = DateTime.now().add(const Duration(days: 30));
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _discountPercentageController.dispose();
    super.dispose();
  }

  Future<void> _saveDiscount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    num? discountPercentage = num.tryParse(
      _discountPercentageController.text.trim(),
    );

    final request = {
      "code": _codeController.text.trim().toUpperCase(),
      "discountPercentage": discountPercentage,
      "validFrom": _validFrom!.toIso8601String(),
      "validTo": _validTo!.toIso8601String(),
      "isActive": _isActive,
    };

    try {
      String successMessage;
      if (!isEditMode) {
        await _discountProvider.insert(request);
        successMessage = "Popust uspješno dodan.";
      } else {
        await _discountProvider.update(widget.discount!.id, request);
        successMessage = "Podaci o popustu uspješno ažurirani.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Greška pri spremanju popusta: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickDateTime({
    required bool isFrom,
    required FormFieldState<DateTime> field,
  }) async {
    final now = DateTime.now();
    DateTime initialDatePickerDate =
        field.value ?? (isFrom ? _validFrom : _validTo) ?? now;

    if (!isFrom &&
        _validFrom != null &&
        initialDatePickerDate.isBefore(_validFrom!)) {
      initialDatePickerDate = _validFrom!;
    }

    if (isFrom &&
        _validTo != null &&
        initialDatePickerDate.isAfter(_validTo!)) {}

    final date = await showDatePicker(
      context: context,
      initialDate: initialDatePickerDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (date == null || !mounted) return;

    final selectedDateTime = DateTime(date.year, date.month, date.day, 0, 0, 0);

    setState(() {
      if (isFrom) {
        _validFrom = selectedDateTime;

        if (_validTo != null && _validTo!.isBefore(_validFrom!)) {
          _validTo = _validFrom!.add(const Duration(days: 1));
        }
      } else {
        _validTo = selectedDateTime;
      }
    });
    field.didChange(selectedDateTime);
    _formKey.currentState?.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Uredi popust" : "Dodaj novi popust"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                label: "Kod popusta (npr. LJETO20)",
                controller: _codeController,
                inputFormatters: [UpperCaseTextFormatter()],
                requiredErrorMsg: "Unesite kod popusta.",
                customValidator: (value) {
                  if (value == null || value.isEmpty) return null;
                  if (value.length < 3 || value.length > 20) {
                    return "Kod mora biti između 3 i 20 karaktera.";
                  }
                  if (RegExp(r'\s').hasMatch(value)) {
                    return "Kod ne smije sadržavati razmake.";
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: "Procenat popusta (npr. 10 za 10%)",
                controller: _discountPercentageController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: false,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                requiredErrorMsg: "Unesite procenat popusta.",
                customValidator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final percentage = int.tryParse(value);
                  if (percentage == null) {
                    return 'Unesite validan cijeli broj.';
                  }
                  if (percentage <= 0 || percentage > 100) {
                    return 'Procenat mora biti između 1 i 100.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDateTimeFieldWrapper(
                label: "Važi od",
                value: _validFrom,
                isFrom: true,
                validator: (value) {
                  if (value == null) return 'Odaberite datum početka važenja.';
                  if (_validTo != null &&
                      !value.isBefore(_validTo!.add(const Duration(days: 1)))) {
                    return 'Datum "Važi od" mora biti prije datuma "Važi do".';
                  }
                  if (!isEditMode &&
                      value.isBefore(
                        DateTime.now().subtract(const Duration(days: 1)),
                      )) {
                    return 'Datum "Važi od" ne može biti u prošlosti za novi popust.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDateTimeFieldWrapper(
                label: "Važi do",
                value: _validTo,
                isFrom: false,
                validator: (value) {
                  if (value == null) return 'Odaberite datum isteka.';
                  if (_validFrom != null &&
                      !value.isAfter(
                        _validFrom!.subtract(const Duration(days: 1)),
                      )) {
                    return 'Datum "Važi do" mora biti nakon datuma "Važi od".';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Popust aktivan"),
                value: _isActive,
                onChanged: (bool value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                secondary: Icon(
                  _isActive ? Icons.check_circle : Icons.cancel_outlined,
                  color: _isActive ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveDiscount,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEditMode ? "Spremi promjene" : "Dodaj popust"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? requiredErrorMsg,
    String? Function(String?)? customValidator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization:
            (inputFormatters?.any((f) => f is UpperCaseTextFormatter) ?? false)
                ? TextCapitalization.characters
                : TextCapitalization.none,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          final val = value?.trim() ?? '';
          if (requiredErrorMsg != null && val.isEmpty) {
            return requiredErrorMsg;
          }
          if (customValidator != null) {
            return customValidator(val);
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateTimeFieldWrapper({
    required String label,
    required DateTime? value,
    required bool isFrom,
    required String? Function(DateTime?) validator,
  }) {
    return FormField<DateTime>(
      initialValue: value,
      validator: validator,
      builder: (FormFieldState<DateTime> field) {
        final displayValue = field.value;
        final String textToShow =
            displayValue != null
                ? DateFormat('dd.MM.yyyy').format(displayValue)
                : "Odaberite datum";

        return InkWell(
          onTap: () => _pickDateTime(isFrom: isFrom, field: field),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              errorText: field.errorText,
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(
              textToShow,
              style: TextStyle(
                fontSize: 16,
                color:
                    displayValue != null ? null : Theme.of(context).hintColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
