import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    if (user == null) {
      return const Center(child: Text('No hay información de usuario'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    user.username.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.username,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ID: ${user.usuarioId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Información
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información de Usuario',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.person_outline,
                    title: 'ID de Persona',
                    value: user.personaId.toString(),
                  ),
                  const Divider(),
                  _buildInfoRow(
                    icon: Icons.business_outlined,
                    title: 'Empresas',
                    value: user.empresaIds,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    icon: Icons.check_circle_outline,
                    title: 'Estado',
                    value: user.isActivo ? 'Activo' : 'Inactivo',
                    valueColor: user.isActivo ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Fechas
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fechas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (user.createdAt != null) ...[
                    _buildInfoRow(
                      icon: Icons.calendar_today_outlined,
                      title: 'Creado',
                      value: _formatDate(user.createdAt!),
                    ),
                    const Divider(),
                  ],
                  if (user.updatedAt != null) ...[
                    _buildInfoRow(
                      icon: Icons.update_outlined,
                      title: 'Actualizado',
                      value: _formatDate(user.updatedAt!),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Botón de cerrar sesión
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cerrar sesión'),
                    content: const Text('¿Estás seguro que deseas cerrar sesión?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          authProvider.logout();
                        },
                        child: const Text('Cerrar sesión'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
