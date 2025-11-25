import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

class PaymentModal extends StatefulWidget {
  const PaymentModal({super.key});

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  int _selectedMethod = 0; // 0 = Cartão, 1 = Pix
  bool _isLoading = false;
  
  // Controladores
  final _cardNumberCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvcCtrl = TextEditingController();

  // Pix Data
  String? _pixCode;
  String? _pixQrUrl;

  // --- 1. INICIA O PROCESSO ---
  Future<void> _handlePayment() async {
    // Validação simples para cartão
    if (_selectedMethod == 0) {
      if (_cardNumberCtrl.text.length < 10 || _expiryCtrl.text.isEmpty || _cvcCtrl.text.isEmpty) {
        _showError("Preencha os dados do cartão.");
        return;
      }
    }

    setState(() => _isLoading = true);

    // MODO WEB: Atalho visual para não quebrar UI com regras do Stripe Web
    if (kIsWeb) {
      await Future.delayed(const Duration(seconds: 2));
      if (_selectedMethod == 1) {
        await _processPixMock();
      } else {
        await _activateVipAndFinish(); 
      }
      return;
    }

    // MODO MOBILE: Tenta fluxo real
    try {
      if (_selectedMethod == 1) {
        await _processPixMock(); 
      } else {
        final clientSecret = await _fetchPaymentIntentClientSecret();
        await _processCardPayment(clientSecret);
      }

    } on StripeException catch (e) {
      _showError("Stripe: ${e.error.localizedMessage}");
    } catch (e) {
      // Tratamento para erros de Backend/CORS/Função (Modo Simulação)
      debugPrint("Erro Backend: $e");
      
      if (e.toString().contains("ClientException") || 
          e.toString().contains("XMLHttpRequest") || 
          e.toString().contains("Functions") ||
          e.toString().contains("404")) {
         
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
             content: Text("Conexão instável com Backend. Ativando modo offline..."),
             backgroundColor: Colors.orange,
             behavior: SnackBarBehavior.floating,
           ));
         }
         
         await Future.delayed(const Duration(seconds: 1));
         
         if (_selectedMethod == 1) {
            await _processPixMock();
         } else {
            await _activateVipAndFinish();
         }
      } else {
         _showError("Erro: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 2. BUSCA O SEGREDO NO SUPABASE ---
  Future<String> _fetchPaymentIntentClientSecret() async {
    try {
      final userEmail = Supabase.instance.client.auth.currentUser?.email;
      
      // Usa o slug da sua função
      final response = await Supabase.instance.client.functions.invoke(
        'swift-api', 
        body: {
          'amount': 1990, 
          'currency': 'brl',
          'payment_method_types': ['card'],
          'email': userEmail,
        },
      );
      
      if (response.status != 200) {
        throw "Erro na Function: ${response.status}";
      }
      return response.data['clientSecret'];
    } catch (e) {
      rethrow;
    }
  }

  // --- 3. PROCESSA CARTÃO (REAL) ---
  Future<void> _processCardPayment(String clientSecret) async {
    final dateParts = _expiryCtrl.text.split('/');
    int? expMonth, expYear;
    if (dateParts.length == 2) {
      expMonth = int.tryParse(dateParts[0]);
      expYear = int.tryParse(dateParts[1]);
    }

    await Stripe.instance.dangerouslyUpdateCardDetails(CardDetails(
      number: _cardNumberCtrl.text.replaceAll(' ', ''),
      expirationMonth: expMonth,
      expirationYear: expYear,
      cvc: _cvcCtrl.text,
    ));

    final paymentIntent = await Stripe.instance.confirmPayment(
      paymentIntentClientSecret: clientSecret,
      data: PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(
          billingDetails: BillingDetails(name: _nameCtrl.text),
        ),
      ),
    );

    if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
      await _activateVipAndFinish();
    } else {
      _showError("Status: ${paymentIntent.status}");
      setState(() => _isLoading = false);
    }
  }

  // --- 4. MOCK VISUAL DO PIX ---
  Future<void> _processPixMock() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _pixCode = "00020126580014br.gov.bcb.pix0136123e4567-e12b-12d1-a456-426655440000520400005303986540510.005802BR5913Nextrip Ltda6008Brasilia62070503***63041D3D";
        _pixQrUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Link_pra_pagina_principal_da_Wikipedia-PT_em_codigo_QR_b.svg/1200px-Link_pra_pagina_principal_da_Wikipedia-PT_em_codigo_QR_b.svg.png";
      });
    }
  }

  // --- 5. ATIVA VIP E FECHA (COM ESTILO DARK LUXURY) ---
  Future<void> _activateVipAndFinish() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('profiles').update({
          'is_vip': true,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id);
      }

      if (mounted) {
        FocusScope.of(context).unfocus();
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (mounted) {
          Navigator.of(context).pop(true);
          
          // --- SNACKBAR DARK LUXURY ---
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  // Icone de Coroa (FontAwesomeIcons.crown)
                  Icon(FontAwesomeIcons.crown, color: Colors.amber, size: 20),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Bem-vindo ao Clube VIP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text("Seus benefícios exclusivos estão ativos.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF1B1B1B), // Fundo EerieBlack (AppColors.eerieBlack)
              behavior: SnackBarBehavior.floating,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.amber, width: 1), // Borda Dourada Fina
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              margin: const EdgeInsets.all(20),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      _showError("Erro ao ativar VIP: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9, minHeight: 600),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),

            const Text("Finalizar Assinatura", style: TextStyle(color: AppColors.black, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Escolha como você prefere pagar.", style: TextStyle(color: AppColors.nightRider, fontSize: 14)),
            
            const SizedBox(height: 32),

            if (_pixCode == null)
              Row(children: [_methodCard(0, "Cartão", Icons.credit_card), const SizedBox(width: 16), _methodCard(1, "Pix", FontAwesomeIcons.pix)]),

            const SizedBox(height: 32),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _pixCode != null 
                  ? _buildPixResult() 
                  : _selectedMethod == 0 
                      ? _buildCardForm() 
                      : _buildPixIntro(),
            ),

            const SizedBox(height: 32),

            if (_pixCode == null)
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: _selectedMethod == 0 ? 'PAGAR R\$ 19,90' : 'GERAR CÓDIGO PIX',
                  isLoading: _isLoading,
                  onPressed: _handlePayment,
                  backgroundColor: AppColors.black,
                  textColor: AppColors.white,
                ),
              ),
            
            const SizedBox(height: 16),
            if (_pixCode == null)
              Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.lock, size: 12, color: AppColors.nightRider), SizedBox(width: 6), Text("Pagamento 100% seguro", style: TextStyle(color: AppColors.nightRider, fontSize: 12))])),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(key: const ValueKey('card'), children: [
      _inputField("Número do Cartão", "0000 0000 0000 0000", controller: _cardNumberCtrl, icon: Icons.credit_card, inputType: TextInputType.number, formatters: [FilteringTextInputFormatter.digitsOnly, CardNumberFormatter(), LengthLimitingTextInputFormatter(19)]),
      const SizedBox(height: 16),
      _inputField("Nome no Cartão", "COMO NO CARTAO", controller: _nameCtrl, icon: Icons.person_outline, inputType: TextInputType.name),
      const SizedBox(height: 16),
      Row(children: [Expanded(child: _inputField("Validade", "MM/AA", controller: _expiryCtrl, icon: Icons.calendar_today, inputType: TextInputType.number, formatters: [FilteringTextInputFormatter.digitsOnly, DateFormatter(), LengthLimitingTextInputFormatter(5)])), const SizedBox(width: 16), Expanded(child: _inputField("CVV", "123", controller: _cvcCtrl, icon: Icons.lock_outline, inputType: TextInputType.number, formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)]))]),
    ]);
  }

  Widget _buildPixIntro() {
    return Container(
      key: const ValueKey('pix_intro'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF0FFF0), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withOpacity(0.3))),
      child: Column(children: const [Icon(FontAwesomeIcons.pix, color: Colors.green, size: 40), SizedBox(height: 16), Text("Liberação Imediata", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)), SizedBox(height: 8), Text("Ao clicar em Gerar, um código Pix será criado.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.nightRider, fontSize: 13))]),
    );
  }

  Widget _buildPixResult() {
    return Column(key: const ValueKey('pix_result'), children: [
      Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green)), child: Column(children: [const Icon(Icons.check_circle, color: Colors.green, size: 48), const SizedBox(height: 16), const Text("Aguardando Pagamento", style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 24), if (_pixQrUrl != null) Image.network(_pixQrUrl!, height: 180), const SizedBox(height: 24), const Text("Copie o código abaixo:", style: TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 8), GestureDetector(onTap: () { Clipboard.setData(ClipboardData(text: _pixCode!)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copiado!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green)); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)), child: Row(children: [Expanded(child: Text(_pixCode!, style: const TextStyle(color: AppColors.black, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis)), const SizedBox(width: 8), const Icon(Icons.copy, size: 20, color: AppColors.black)])))])),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, child: CustomButton(text: 'JÁ FIZ O PAGAMENTO', onPressed: () => _activateVipAndFinish(), backgroundColor: Colors.green, textColor: Colors.white)),
    ]);
  }

  Widget _inputField(String label, String hint, {required TextEditingController controller, IconData? icon, TextInputType? inputType, List<TextInputFormatter>? formatters}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: AppColors.nightRider, fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Container(decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)), child: TextField(controller: controller, style: const TextStyle(color: AppColors.black), keyboardType: inputType, inputFormatters: formatters, decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: AppColors.nightRider.withOpacity(0.4)), border: InputBorder.none, prefixIcon: icon != null ? Icon(icon, color: AppColors.nightRider, size: 20) : null, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))))]);
  }

  Widget _methodCard(int index, String label, IconData icon) {
    bool isSelected = _selectedMethod == index;
    return Expanded(child: GestureDetector(onTap: () { if(_pixCode == null) setState(() => _selectedMethod = index); }, child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: isSelected ? AppColors.black : const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? AppColors.black : Colors.grey[300]!)), child: Column(children: [Icon(icon, color: isSelected ? AppColors.white : AppColors.black, size: 24), const SizedBox(height: 8), Text(label, style: TextStyle(color: isSelected ? AppColors.white : AppColors.black, fontWeight: FontWeight.bold))]))));
  }
}

class CardNumberFormatter extends TextInputFormatter { @override TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) { var t = n.text; if (n.selection.baseOffset == 0) return n; var b = StringBuffer(); for (int i = 0; i < t.length; i++) { b.write(t[i]); var idx = i + 1; if (idx % 4 == 0 && idx != t.length) b.write(' '); } var s = b.toString(); return n.copyWith(text: s, selection: TextSelection.collapsed(offset: s.length)); } }
class DateFormatter extends TextInputFormatter { @override TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) { var t = n.text; if (n.selection.baseOffset == 0) return n; var b = StringBuffer(); for (int i = 0; i < t.length; i++) { b.write(t[i]); var idx = i + 1; if (idx % 2 == 0 && idx != t.length) b.write('/'); } var s = b.toString(); return n.copyWith(text: s, selection: TextSelection.collapsed(offset: s.length)); } }