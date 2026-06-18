import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../widgets/app_scaffold.dart';

class OperaScreen extends StatefulWidget {
  const OperaScreen({super.key});

  @override
  State<OperaScreen> createState() => _OperaScreenState();
}

class _OperaScreenState extends State<OperaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Operaciones',
      currentIndex: 1,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOperacionesGrid(context),
                _buildFavoritosTab(),
              ],
            ),
          ),
        ],
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
          'Operaciones',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.naranjaBCP,
        indicatorWeight: 3,
        labelColor: AppColors.azulPrincipal,
        unselectedLabelColor: const Color(0xFF98A2B3),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        tabs: const [
          Tab(text: 'Operaciones'),
          Tab(text: 'Favoritos'),
        ],
      ),
    );
  }

  Widget _buildOperacionesGrid(BuildContext context) {
    final operations = [
      (Icons.swap_horiz, 'Transferir\ndinero', AppRoutes.transferencias),
      (Icons.water_drop_outlined, 'Pagar\nservicios', AppRoutes.pagos),
      (Icons.send_rounded, 'Yapear a\ncelular', AppRoutes.transferencias),
      (Icons.qr_code_scanner, 'Pagar\ncon QR', AppRoutes.pagos),
      (Icons.currency_exchange, 'Cambia soles\ny dólares', ''),
      (Icons.phone_android_outlined, 'Recargar\ncelular', ''),
      (Icons.favorite_border_outlined, 'Realizar\ndonaciones', ''),
      (Icons.atm_outlined, 'Retirar\nsin tarjeta', ''),
      (Icons.credit_card_outlined, 'Pagar\ntarjetas', AppRoutes.tarjeta),
      (Icons.account_balance_outlined, 'Pagar\ncréditos', AppRoutes.creditos),
      (Icons.monetization_on_outlined, 'Disponer de\nefectivo', AppRoutes.prestamo),
      (Icons.savings_outlined, 'Wardaditos\n', AppRoutes.ahorro),
      (Icons.wallet_outlined, 'Depósito a\nplazo', ''),
      (Icons.password_outlined, 'Cambiar\nClave PIN', ''),
    ];

    return Container(
      color: const Color(0xFFF5F7FA),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: operations.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, i) {
          final op = operations[i];
          return InkWell(
            onTap: () {
              if (op.$3.isNotEmpty) {
                Navigator.pushNamed(context, op.$3);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${op.$2.replaceAll('\n', ' ')} - Próximamente')),
                );
              }
            },
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE4E7EC)),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE6F0FA),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(op.$1, color: AppColors.azulPrincipal, size: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      op.$2,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulPrincipal,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoritosTab() {
    return Container(
      color: const Color(0xFFF5F7FA),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.star_border, size: 48, color: Color(0xFF98A2B3)),
            SizedBox(height: 16),
            Text(
              'Aún no tienes operaciones favoritas',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.azulPrincipal,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Agrega tus operaciones frecuentes para acceder más rápido.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF667085),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
