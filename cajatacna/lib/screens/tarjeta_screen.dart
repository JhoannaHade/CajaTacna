import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/tarjeta_models.dart';
import '../repositories/tarjeta_repository.dart';
import '../core/network/supabase_client.dart';
import '../widgets/app_scaffold.dart';

class TarjetaScreen extends StatefulWidget {
  const TarjetaScreen({super.key});

  @override
  State<TarjetaScreen> createState() => _TarjetaScreenState();
}

class _TarjetaScreenState extends State<TarjetaScreen> {
  List<Tarjeta> _tarjetas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTarjetas();
  }

  Future<void> _loadTarjetas() async {
    try {
      final repo = TarjetaRepository(SupabaseClient());
      final tarjetas = await repo.getTarjetas();
      if (mounted) setState(() { _tarjetas = tarjetas; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Mis Tarjetas',
      currentIndex: 0,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.rojoError)))
              : _tarjetas.isEmpty
                  ? const Center(child: Text('No tienes tarjetas registradas.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tarjetas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _TarjetaCard(tarjeta: _tarjetas[index]);
                      },
                    ),
    );
  }
}

class _TarjetaCard extends StatelessWidget {
  final Tarjeta tarjeta;
  const _TarjetaCard({required this.tarjeta});

  @override
  Widget build(BuildContext context) {
    final isCredito = tarjeta.tipo.toLowerCase().contains('credito') ||
        tarjeta.tipo.toLowerCase().contains('crédito');
    final isVisa = tarjeta.marca.toLowerCase() == 'visa';

    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isCredito
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [AppColors.azulPrincipal, AppColors.azulSecundario],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCredito ? Colors.black : AppColors.azulPrincipal).withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Círculos decorativos
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tarjeta.tipo.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      tarjeta.marca.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  tarjeta.numero,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VENCE',
                          style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1),
                        ),
                        Text(
                          tarjeta.fechaVencimiento,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isVisa ? 'VISA' : tarjeta.marca.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
