import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../widgets/app_scaffold.dart';

class ParaTiScreen extends StatelessWidget {
  const ParaTiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Para ti',
      currentIndex: 2,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildOfertasEspeciales(),
            _buildQoreBanner(),
            _buildOtrosProductos(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.azulPrincipal,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: const Center(
        child: Text(
          'Para ti',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOfertasEspeciales() {
    return Container(
      color: const Color(0xFFF5F7FA),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Styled title banner
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEBF3FC), Color(0xFFD6E6F7)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Tus ofertas ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: AppColors.azulPrincipal,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      TextSpan(
                        text: 'Especiales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.azulPrincipal,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.phone_android_outlined, color: AppColors.naranjaBCP, size: 24),
              ],
            ),
          ),
          // Oferta 1
          _buildOfertaCard(
            title: 'Seguro Vida Devolución',
            subtitle: 'Con el respaldo de Pacífico Seguros',
            icon: Icons.shield_outlined,
            iconBgColor: const Color(0xFFEBF3FC),
            iconColor: AppColors.azulPrincipal,
          ),
          // Oferta 2
          _buildOfertaCard(
            title: 'Protección de Tarjetas Plus',
            subtitle: 'Por menos de S/0.50 al día, protégete ante robos y/o fraudes.',
            icon: Icons.credit_card_outlined,
            iconBgColor: const Color(0xFFFFF0E6),
            iconColor: AppColors.naranjaBCP,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOfertaCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              )
            : null,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFF2F4F7)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulPrincipal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQoreBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFF2F4F7)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.azulPrincipal, AppColors.azulSecundario],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_border, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Tu mundo de beneficios ahora es Qore.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulPrincipal,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Descúbrelo ahora',
                      style: TextStyle(
                        color: AppColors.naranjaBCP,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtrosProductos(BuildContext context) {
    final products = [
      (Icons.monetization_on_outlined, 'Préstamos', AppRoutes.prestamo),
      (Icons.credit_card_outlined, 'Tarjetas', AppRoutes.tarjeta),
      (Icons.trending_up_outlined, 'Inversiones', ''),
      (Icons.account_balance_wallet_outlined, 'Cuentas', AppRoutes.cuenta),
      (Icons.favorite_border_outlined, 'Seguros', ''),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: const Color(0xFFF5F7FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Otros productos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.azulPrincipal,
                ),
              ),
              InkWell(
                onTap: () {},
                child: Row(
                  children: const [
                    Text(
                      'Ver todos',
                      style: TextStyle(
                        color: AppColors.naranjaBCP,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, color: AppColors.naranjaBCP, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF2F4F7), indent: 56),
              itemBuilder: (context, i) {
                final prod = products[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: Icon(prod.$1, color: AppColors.azulPrincipal),
                  title: Text(
                    prod.$2,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.azulPrincipal,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF98A2B3), size: 14),
                  onTap: () {
                    if (prod.$3.isNotEmpty) {
                      Navigator.pushNamed(context, prod.$3);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${prod.$2} - Disponible próximamente')),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
