import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/errors/location_failure.dart';
import '../../data/models/location_history_item.dart';
import '../providers/location_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Trigger initial permission and position check quietly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LocationProvider>().init().then((_) {
        if (!mounted) return;
        final failure = context.read<LocationProvider>().failure;
        if (failure != null) {
          _showErrorSnackBar(failure.message);
        }
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          _showErrorSnackBar('No se pudo abrir la aplicación de mapas.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error al intentar abrir Google Maps: $e');
      }
    }
  }

  Future<void> _confirmClearHistory(BuildContext context, LocationProvider provider) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 10),
              Text('¿Borrar Historial?'),
            ],
          ),
          content: const Text(
            'Esta acción eliminará todas las ubicaciones guardadas localmente de forma permanente. ¿Deseas continuar?',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Borrar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await provider.clearHistory();
      if (mounted) {
        _showSuccessSnackBar('Historial borrado correctamente.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE8F5E9), // Very light green
            Color(0xFFF1F8E9), // Mint green
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.gps_fixed_rounded, color: Color(0xFF2E7D32)),
              SizedBox(width: 8),
              Text('GPS Antigravity Tracker'),
            ],
          ),
        ),
        body: Consumer<LocationProvider>(
          builder: (context, provider, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Current location status card
                    SliverToBoxAdapter(
                      child: _buildCurrentLocationCard(provider),
                    ),

                    // History section header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Historial (${provider.history.length}/30)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            if (provider.history.isNotEmpty)
                              IconButton(
                                icon: Icon(Icons.delete_sweep_rounded, color: Theme.of(context).colorScheme.error, size: 28),
                                onPressed: () => _confirmClearHistory(context, provider),
                                tooltip: 'Borrar historial',
                              ),
                          ],
                        ),
                      ),
                    ),

                    // History list
                    if (provider.history.isEmpty)
                      SliverToBoxAdapter(
                        child: _buildEmptyHistoryPlaceholder(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = provider.history[index];
                              return _buildHistoryItemCard(item, index);
                            },
                            childCount: provider.history.length,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentLocationCard(LocationProvider provider) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.green[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ubicación GPS Actual',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (provider.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                else
                  Icon(
                    provider.currentPosition != null ? Icons.gps_fixed : Icons.gps_off,
                    color: provider.currentPosition != null ? Colors.green : Colors.grey,
                  ),
              ],
            ),
            const Divider(height: 24, thickness: 1.2),
            
            if (provider.failure != null) ...[
              _buildErrorWidget(provider),
            ] else if (provider.currentPosition == null) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(Icons.location_searching_rounded, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'Presiona "Actualizar" para obtener coordenadas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              _buildLocationDetailsGrid(provider),
            ],

            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.isLoading
                        ? null
                        : () => provider.fetchLocation().then((_) {
                            if (provider.failure != null) {
                              _showErrorSnackBar(provider.failure!.message);
                            } else {
                              _showSuccessSnackBar('Ubicación actualizada con éxito.');
                            }
                          }),
                    icon: const Icon(Icons.sync_rounded),
                    label: const Text('Actualizar'),
                  ),
                ),
                if (provider.currentPosition != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openGoogleMaps(
                        provider.currentPosition!.latitude,
                        provider.currentPosition!.longitude,
                      ),
                      icon: const Icon(Icons.map_rounded),
                      label: const Text('Google Maps'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(LocationProvider provider) {
    final failure = provider.failure!;
    final isGpsDisabled = failure.type == LocationFailureType.servicesDisabled;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  failure.message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (isGpsDisabled || failure.type == LocationFailureType.permissionDeniedForever) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => provider.openAppropriateSettings(),
                icon: const Icon(Icons.settings),
                label: Text(
                  isGpsDisabled ? 'Activar GPS (Ajustes)' : 'Abrir Ajustes de la App',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationDetailsGrid(LocationProvider provider) {
    final pos = provider.currentPosition!;
    final time = provider.currentTime!;

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 2.2,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildDetailTile('Latitud', '${pos.latitude.toStringAsFixed(6)}°', Icons.explore_rounded, Colors.blue),
        _buildDetailTile('Longitud', '${pos.longitude.toStringAsFixed(6)}°', Icons.explore_rounded, Colors.purple),
        _buildDetailTile('Precisión', '${pos.accuracy.toStringAsFixed(1)} m', Icons.gps_fixed_rounded, Colors.teal),
        _buildDetailTile('Hora', time, Icons.access_time_rounded, Colors.orange),
      ],
    );
  }

  Widget _buildDetailTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryPlaceholder() {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.green.withValues(alpha: 0.15)),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        child: Column(
          children: [
            Icon(Icons.history_toggle_off_rounded, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No hay registros en el historial',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 4),
            Text(
              'Las coordenadas obtenidas se guardarán automáticamente aquí (máx. 30).',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItemCard(LocationHistoryItem item, int index) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green.withValues(alpha: 0.08)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openGoogleMaps(item.latitude, item.longitude),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Circular index tag
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFC8E6C9),
                foregroundColor: const Color(0xFF2E7D32),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 14),
              
              // Coordinates details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Lat: ${item.latitude.toStringAsFixed(5)}°',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Lng: ${item.longitude.toStringAsFixed(5)}°',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Precisión: ${item.accuracy.toStringAsFixed(1)}m',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const Spacer(),
                        const Icon(Icons.access_time, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          item.time,
                          style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              
              // Action indicator
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}
