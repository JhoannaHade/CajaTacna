import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/app_scaffold.dart';

class NotificaScreen extends StatelessWidget {
  const NotificaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Notificaciones',
      currentIndex: 3,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _NotificationItem(
            icon: Icons.arrow_downward,
            title: 'Depósito Recibido',
            subtitle: 'S/ 500.00',
            time: 'Hace 2 horas',
            color: AppColors.verdeExito,
          ),
          _NotificationItem(
            icon: Icons.arrow_upward,
            title: 'Retiro de Fondos',
            subtitle: 'S/ 200.00',
            time: 'Hace 5 horas',
            color: AppColors.rojoError,
          ),
          _NotificationItem(
            icon: Icons.credit_card,
            title: 'Pago de Tarjeta',
            subtitle: 'S/ 1,500.00',
            time: 'Hace 1 día',
            color: AppColors.azulPrincipal,
          ),
          const SizedBox(height: 24),
          const Text(
            'Oportunidades',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _NotificationItem(
            icon: Icons.local_offer,
            title: 'Oferta Especial',
            subtitle: 'Tasa de interés reducida',
            time: 'Hace 3 días',
            color: AppColors.naranjaBCP,
          ),
          _NotificationItem(
            icon: Icons.star,
            title: 'Promoción',
            subtitle: 'Gana puntos con tus transacciones',
            time: 'Hace 5 días',
            color: AppColors.naranjaBCP,
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(fontSize: 12, color: AppColors.grisTexto),
            ),
          ],
        ),
      ),
    );
  }
}
