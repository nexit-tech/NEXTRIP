import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

class SubscriptionManagementModal extends StatelessWidget {
  final VoidCallback onCancelSubscription; // Função chamada ao cancelar

  const SubscriptionManagementModal({
    super.key,
    required this.onCancelSubscription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.eerieBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: AppColors.nightRider, borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // Título
          Row(
            children: const [
              Icon(FontAwesomeIcons.crown, color: AppColors.white, size: 20),
              SizedBox(width: 12),
              Text("Sua Assinatura VIP", style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          
          const SizedBox(height: 32),

          // Card de Informações
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.nightRider),
            ),
            child: Column(
              children: [
                _infoRow("Status", "ATIVO", color: Colors.greenAccent),
                const Divider(color: AppColors.nightRider, height: 24),
                _infoRow("Plano", "Mensal"),
                const SizedBox(height: 12),
                _infoRow("Desde", "20/11/2025"),
                const SizedBox(height: 12),
                _infoRow("Próxima Cobrança", "20/12/2025"),
                const SizedBox(height: 12),
                _infoRow("Valor", "R\$ 19,90"),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Botão Cancelar (Vermelho/Alerta)
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'CANCELAR ASSINATURA',
              isOutlined: true,
              textColor: Colors.redAccent, // Texto vermelho
              icon: Icons.cancel_outlined,
              onPressed: () {
                // Mostra confirmação
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.eerieBlack,
                    title: const Text("Tem certeza?", style: TextStyle(color: AppColors.white)),
                    content: const Text(
                      "Ao cancelar, você perderá o acesso aos cupons exclusivos no final do ciclo atual (20/12/2025).",
                      style: TextStyle(color: AppColors.chineseWhite),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Voltar", style: TextStyle(color: AppColors.white)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Fecha o dialog
                          onCancelSubscription(); // Executa o cancelamento
                          Navigator.pop(context); // Fecha o modal
                        },
                        child: const Text("Confirmar Cancelamento", style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color color = AppColors.white}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.chineseWhite, fontSize: 14)),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}