import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/responsive.dart';
import '../core/utils/date_helper.dart';
import '../model/order_model.dart';
import 'panel.dart';
import 'status_chip.dart';

/// One order summary – used by customer, mavshi and delivery screens.
class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  /// show customer name + address (mavshi / delivery view)
  final bool showCustomer;

  /// show the mess name (customer / delivery view)
  final bool showMess;

  /// buttons under the card (role specific actions)
  final List<Widget> actions;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.showCustomer = false,
    this.showMess = false,
    this.actions = const [],
  });

  Widget _line(IconData icon, String text) => Padding(
        padding: EdgeInsets.only(top: Responsive.w(4)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: Responsive.w(16), color: AppColors.primaryOrange),
            SizedBox(width: Responsive.w(6)),
            Expanded(child: Text(text, style: AppTextStyles.bodyGrey)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final itemsText = order.items.map((i) => '${i.name} × ${i.quantity}').join(', ');
    final address = [order.address, order.areaName, order.pincode]
        .where((s) => s.isNotEmpty)
        .join(', ');

    return Panel(
      onTap: onTap,
      margin: EdgeInsets.only(bottom: Responsive.w(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('ऑर्डर #${order.shortId}', style: AppTextStyles.cardTitle)),
              StatusChip(order.status),
            ],
          ),
          if (showMess && order.messName.isNotEmpty) _line(Icons.storefront_rounded, order.messName),
          if (showCustomer && order.customerName.isNotEmpty)
            _line(Icons.person_outline_rounded,
                '${order.customerName}${order.customerMobile.isEmpty ? '' : '  •  ${order.customerMobile}'}'),
          if (itemsText.isNotEmpty) _line(Icons.restaurant_menu_rounded, itemsText),
          if (order.plan.isNotEmpty || order.startDate.isNotEmpty)
            _line(Icons.event_rounded,
                '${order.plan}${order.startDate.isEmpty ? '' : '  •  सुरुवात ${DateHelper.fromApi(order.startDate)}'}'),
          if (showCustomer && address.isNotEmpty) _line(Icons.location_on_outlined, address),
          SizedBox(height: Responsive.w(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.paymentMethod == 'COD' ? 'COD' : (order.paymentMethod.isEmpty ? '' : 'ऑनलाइन'),
                  style: AppTextStyles.caption),
              Text('₹${order.total}',
                  style: AppTextStyles.subHeading.copyWith(color: AppColors.primaryGreen)),
            ],
          ),
          if (actions.isNotEmpty) ...[
            SizedBox(height: Responsive.w(10)),
            ...actions,
          ],
        ],
      ),
    );
  }
}
