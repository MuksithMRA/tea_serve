import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tea_order.dart';
import '../providers/drink_selection_provider.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../widgets/drink_grid.dart';
import '../widgets/order_list.dart';
import '../widgets/selection_popup.dart';
import 'login_screen.dart';

class EmployeeScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const EmployeeScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final orderService = OrderService();
  bool _isPlacingOrder = false;

  Future<void> _placeOrder(BuildContext context, DrinkType drinkType) async {
    if (_isPlacingOrder) return;
    
    setState(() {
      _isPlacingOrder = true;
    });

    try {
      await orderService.createOrder(
        TeaOrder(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: widget.userId,
          userName: widget.userName,
          orderTime: DateTime.now(),
          status: OrderStatus.pending,
          drinkType: drinkType,
        ),
      );
      if (!mounted) return;
      Provider.of<DrinkSelectionProvider>(context, listen: false).selectDrink(null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2)],
              ),
            ),
            child: RefreshIndicator(
              color: const Color(0xFF8B4513),
              onRefresh: () async {
                setState(() {});
              },
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: const Color(0xFF8B4513),
                    foregroundColor: Colors.white,
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.local_cafe, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tea Port',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.userName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    floating: true,
                    snap: true,
                    elevation: 0,
                    actions: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: () async {
                            final authService = Provider.of<AuthService>(context, listen: false);
                            await authService.signOut();
                            if (!mounted) return;
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF8B4513),
                                    child: Text(
                                      widget.userName[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Select your drink:',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const DrinkGrid(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.history,
                                color: Color(0xFF8B4513),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Your Orders',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  OrderList(
                    userId: widget.userId,
                    orderService: orderService,
                  ),
                ],
              ),
            ),
          ),
          SelectionPopup(
            onPlaceOrder: (drinkType) => _placeOrder(context, drinkType),
            isLoading: _isPlacingOrder,
          ),
        ],
      ),
    );
  }
}
