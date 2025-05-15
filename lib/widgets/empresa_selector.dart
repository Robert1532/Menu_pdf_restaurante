import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../models/empresa.dart';

class EmpresaSelector extends StatelessWidget {
  const EmpresaSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final empresas = authProvider.empresas;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Empresa'),
      ),
      body: empresas.isEmpty
          ? const Center(
              child: Text('No hay empresas disponibles'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: empresas.length,
              itemBuilder: (ctx, index) {
                final empresa = empresas[index];
                final isSelected = authProvider.selectedEmpresaId == empresa.empresaId;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      authProvider.selectEmpresa(empresa.empresaId);
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: empresa.logo != null
                                ? Image.network(
                                    empresa.logo!,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.business,
                                      size: 30,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                : Icon(
                                    Icons.business,
                                    size: 30,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  empresa.nombre,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'ID: ${empresa.empresaId}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 16,
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
}
