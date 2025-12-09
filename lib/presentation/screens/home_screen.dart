import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../providers/auth_provider.dart';
import 'pos/pos_screen.dart';
import 'products/products_screen.dart';
import 'sales/sales_screen.dart';
import 'inventory/inventory_screen.dart';
import 'customers/customers_screen.dart';
import 'reports/reports_screen.dart';
import 'cash_session/cash_session_screen.dart';
import 'settings/settings_screen.dart';
import 'users/users_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.point_of_sale,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'Aronium POS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 0.5,
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.tertiary,
                    ],
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
              ),
            ),
          ],
        ),
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black.withOpacity(0.15),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.grey.shade900,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.red.shade100,
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.logout_rounded,
                color: Colors.red.shade700,
                size: 22,
              ),
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              tooltip: 'Logout',
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        elevation: 2,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Text(
                      user.username[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName ?? user.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.shopping_cart_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text(
                'POS',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PosScreen()),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 4,
              ),
            ),
            if (user.isAdmin || user.isManager) ...[
              ListTile(
                leading: Icon(
                  Icons.inventory_2_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: const Text(
                  'Products',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductsScreen()),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.orange.shade700,
                ),
                title: const Text(
                  'Sales',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SalesScreen()),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.warehouse_rounded,
                  color: Colors.purple.shade600,
                ),
                title: const Text(
                  'Inventory',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InventoryScreen()),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.people_rounded,
                  color: Colors.teal.shade600,
                ),
                title: const Text(
                  'Customers',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomersScreen()),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.assessment_rounded,
                  color: Colors.indigo.shade600,
                ),
                title: const Text(
                  'Reports',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportsScreen()),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
              ),
            ],
            ListTile(
              leading: Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.amber.shade700,
              ),
              title: const Text(
                'Cash Session',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CashSessionScreen()),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 4,
              ),
            ),
            if (user.isAdmin) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Divider(),
              ),
              ListTile(
                leading: Icon(
                  Icons.settings_rounded,
                  color: Colors.grey.shade700,
                ),
                title: const Text(
                  'Settings',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
              ),
            ],
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth > 900;
          final crossAxisCount = isWeb ? 4 : 2;
          final padding = isWeb ? 32.0 : 16.0;
          final spacing = isWeb ? 24.0 : 16.0;
          
          return GridView.count(
            crossAxisCount: crossAxisCount,
            padding: EdgeInsets.all(padding),
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: isWeb ? 1.1 : 1.0,
            children: [
          _buildMenuCard(
            context,
            'POS',
            Icons.shopping_cart,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PosScreen()),
            ),
          ),
          if (user.isAdmin || user.isManager) ...[
            _buildMenuCard(
              context,
              'Products',
              Icons.inventory_2,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductsScreen()),
              ),
            ),
            _buildMenuCard(
              context,
              'Sales',
              Icons.receipt_long,
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SalesScreen()),
              ),
            ),
            _buildMenuCard(
              context,
              'Inventory',
              Icons.warehouse,
              Colors.purple,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InventoryScreen()),
              ),
            ),
            _buildMenuCard(
              context,
              'Customers',
              Icons.people,
              Colors.teal,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomersScreen()),
              ),
            ),
            _buildMenuCard(
              context,
              'Reports',
              Icons.assessment,
              Colors.indigo,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              ),
            ),
          ],
          _buildMenuCard(
            context,
            'Cash Session',
            Icons.money,
            Colors.amber,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CashSessionScreen()),
            ),
          ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return _AnimatedMenuCard(
      title: title,
      icon: icon,
      color: color,
      onTap: onTap,
    );
  }
}

// Animated menu card with hover effect
class _AnimatedMenuCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  
  const _AnimatedMenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  
  @override
  _AnimatedMenuCardState createState() => _AnimatedMenuCardState();
}

class _AnimatedMenuCardState extends State<_AnimatedMenuCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  bool _isHovered = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );
    
    _rotateAnimation = Tween<double>(begin: 0, end: 0.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getTextColor(Color baseColor) {
    // Create a darker, more visible version of the color
    // For light colors like amber/yellow, make it much darker
    final hsl = HSLColor.fromColor(baseColor);
    final lightness = hsl.lightness;
    
    // If the color is light (like amber/yellow), make it much darker
    if (lightness > 0.6) {
      return hsl.withLightness(0.3).withSaturation(0.8).toColor();
    } else {
      // For darker colors, make them slightly darker for better contrast
      return hsl.withLightness((hsl.lightness * 0.7).clamp(0.2, 0.5)).toColor();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
        _controller.forward();
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotateAnimation.value * math.pi,
              child: Card(
                elevation: _isHovered ? 8 : 4,
                shadowColor: widget.color.withOpacity(_isHovered ? 0.3 : 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(24),
                  splashColor: widget.color.withOpacity(0.1),
                  highlightColor: widget.color.withOpacity(0.05),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          widget.color.withOpacity(0.05),
                          widget.color.withOpacity(_isHovered ? 0.15 : 0.1),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.all(_isHovered ? 24 : 22),
                          decoration: BoxDecoration(
                            color: widget.color.withOpacity(_isHovered ? 0.2 : 0.15),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.color.withOpacity(_isHovered ? 0.3 : 0.2),
                                blurRadius: _isHovered ? 20 : 15,
                                spreadRadius: _isHovered ? 3 : 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.8),
                              width: 4,
                            ),
                          ),
                          child: Icon(
                            widget.icon,
                            size: _isHovered ? 54 : 50,
                            color: widget.color,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: _isHovered ? 20 : 18,
                              fontWeight: FontWeight.w600,
                              color: _getTextColor(widget.color),
                              letterSpacing: 0.5,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}