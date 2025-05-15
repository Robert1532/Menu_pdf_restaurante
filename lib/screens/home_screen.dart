import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/empresa_selector.dart';
import '../screens/products_screen.dart';
import '../screens/menu_editor_screen.dart';
import '../screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final selectedEmpresa = authProvider.selectedEmpresa;
    
    // Si no hay empresa seleccionada y hay empresas disponibles
    if (selectedEmpresa == null && authProvider.empresas.isNotEmpty) {
      return const EmpresaSelector();
    }
    
    final List<Widget> _pages = [
      const ProductsScreen(),
      const MenuEditorScreen(),
      const ProfileScreen(),
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedEmpresa?.nombre ?? 'Menú App',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (authProvider.empresas.length > 1)
            IconButton(
              icon: const Icon(Icons.business),
              tooltip: 'Cambiar empresa',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EmpresaSelector()),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
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
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'Productos',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book),
            label: 'Menú',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
