import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

class PaymentModal extends StatefulWidget {
  const PaymentModal({super.key});

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  int _selectedMethod = 0;
  bool _isLoading = false;

  void _handlePayment() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: 600 + bottomInset,
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),

            const Text("Finalizar Assinatura", style: TextStyle(color: AppColors.black, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Escolha como você prefere pagar.", style: TextStyle(color: AppColors.nightRider, fontSize: 14)),
            
            const SizedBox(height: 32),

            Row(
              children: [
                _methodCard(0, "Cartão", Icons.credit_card),
                const SizedBox(width: 16),
                _methodCard(1, "Pix", FontAwesomeIcons.pix),
              ],
            ),

            const SizedBox(height: 32),

            if (_selectedMethod == 0) 
              _buildCardForm()
            else 
              _buildPixInfo(),

            const SizedBox(height: 32),

            // --- BOTÃO AGORA É PRETO ---
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'PAGAR R\$ 19,90',
                isLoading: _isLoading,
                onPressed: _handlePayment,
                // Passando as cores para inverter
                backgroundColor: AppColors.black,
                textColor: AppColors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock, size: 12, color: AppColors.nightRider),
                  SizedBox(width: 6),
                  Text("Pagamento 100% seguro", style: TextStyle(color: AppColors.nightRider, fontSize: 12)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  // ... (O resto do arquivo _buildCardForm, _buildPixInfo, etc. continua igual)
  Widget _buildCardForm() {
    return Column(
      children: [
        _inputField(
          "Número do Cartão", 
          "0000 0000 0000 0000", 
          icon: Icons.credit_card, 
          inputType: TextInputType.number,
          formatters: [FilteringTextInputFormatter.digitsOnly, CardNumberFormatter(), LengthLimitingTextInputFormatter(19)]
        ),
        const SizedBox(height: 16),
        _inputField(
          "Nome no Cartão", 
          "COMO NO CARTAO", 
          icon: Icons.person_outline,
          inputType: TextInputType.name,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _inputField(
                "Validade", 
                "MM/AA", 
                icon: Icons.calendar_today,
                inputType: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly, DateFormatter(), LengthLimitingTextInputFormatter(5)]
              )
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _inputField(
                "CVV", 
                "123", 
                icon: Icons.lock_outline,
                inputType: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)]
              )
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPixInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFF0), 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(FontAwesomeIcons.pix, color: Colors.green, size: 40),
          const SizedBox(height: 16),
          const Text("Liberação Imediata", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Ao clicar em Pagar, um código Pix Copia e Cola será gerado para você.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.nightRider, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _inputField(String label, String hint, {IconData? icon, TextInputType? inputType, List<TextInputFormatter>? formatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.nightRider, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            style: const TextStyle(color: AppColors.black),
            keyboardType: inputType,
            inputFormatters: formatters,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.nightRider.withOpacity(0.4)),
              border: InputBorder.none,
              prefixIcon: icon != null ? Icon(icon, color: AppColors.nightRider, size: 20) : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _methodCard(int index, String label, IconData icon) {
    bool isSelected = _selectedMethod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.black : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.black : Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.white : AppColors.black, size: 24),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: isSelected ? AppColors.white : AppColors.black, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
// ... (Classes de formatação continuam iguais no final do arquivo)
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) buffer.write(' ');
    }
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}

class DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length) buffer.write('/');
    }
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}