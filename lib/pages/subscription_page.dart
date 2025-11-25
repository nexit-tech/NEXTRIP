import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../components/custom_button.dart';
import '../components/benefit_item.dart';
import '../components/payment_modal.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

// Adicionei 'TickerProviderStateMixin' para permitir animações
class _SubscriptionPageState extends State<SubscriptionPage> with TickerProviderStateMixin {
  
  // O Controlador da animação
  late AnimationController _modalController;

  @override
  void initState() {
    super.initState();
    // Define a velocidade: 600 milissegundos (Lento e suave)
    _modalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), 
      reverseDuration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _modalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16, left: 16,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.chineseWhite),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FontAwesomeIcons.crown, size: 64, color: AppColors.white),
                  const SizedBox(height: 24),
                  const Text("NEXTRIP VIP", textAlign: TextAlign.center, style: TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  const Text("Desbloqueie o máximo do seu estilo de vida.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.chineseWhite, fontSize: 14)),

                  const SizedBox(height: 48),

                  const BenefitItem(text: "Acesso ilimitado a todos os cupons"),
                  const BenefitItem(text: "Ofertas 'Secretas' toda semana"),
                  const BenefitItem(text: "Suporte prioritário no WhatsApp"),

                  const SizedBox(height: 48),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: AppColors.eerieBlack,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.nightRider),
                    ),
                    child: Column(
                      children: const [
                        Text("ASSINATURA MENSAL", style: TextStyle(color: AppColors.chineseWhite, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        SizedBox(height: 8),
                        Text("R\$ 19,90", style: TextStyle(color: AppColors.white, fontSize: 40, fontWeight: FontWeight.w900)),
                        SizedBox(height: 4),
                        Text("/mês", style: TextStyle(color: AppColors.chineseWhite, fontSize: 12)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // BOTÃO DE ASSINAR (COM A ANIMAÇÃO LENTA)
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'ASSINAR AGORA',
                      onPressed: () async {
                        final success = await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          transitionAnimationController: _modalController, // <--- O TRUQUE DA VELOCIDADE
                          builder: (context) => const PaymentModal(),
                        );

                        if (success == true && context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Text("Cobrança recorrente. Cancele a qualquer momento.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.chineseWhite.withOpacity(0.6), fontSize: 11, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}