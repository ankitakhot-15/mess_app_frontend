import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/constants/app_enums.dart';
import '../core/responsive.dart';
import '../model/menu_item.dart';

/// Menu row for the customer: price follows the selected plan.
class MenuCard extends StatelessWidget {
  final MenuItem item;
  final OrderPlan plan;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const MenuCard({
    super.key,
    required this.item,
    required this.plan,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Responsive.w(18)),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        children: [
          Container(
            width: Responsive.w(60),
            height: Responsive.w(60),
            alignment: Alignment.center,
            decoration:
                const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
            child: item.imageUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(item.imageUrl,
                        width: Responsive.w(60),
                        height: Responsive.w(60),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Text('🍱', style: TextStyle(fontSize: Responsive.sp(30)))))
                : Text('🍱', style: TextStyle(fontSize: Responsive.sp(30))),
          ),
          SizedBox(width: Responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.circle,
                        size: Responsive.w(10),
                        color: item.isVeg ? AppColors.primaryGreen : AppColors.heartRed),
                    SizedBox(width: Responsive.w(5)),
                    Expanded(child: Text(item.name, style: AppTextStyles.cardTitle)),
                  ],
                ),
                if (item.description.isNotEmpty)
                  Text(item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption),
                Text('${MealTypes.label(item.mealType)}  •  ${FoodTypes.label(item.foodType)}',
                    style: AppTextStyles.caption),
                SizedBox(height: Responsive.w(6)),
                Text('₹${item.priceFor(plan)}  / ${plan.label}',
                    style: AppTextStyles.subHeading.copyWith(color: AppColors.primaryOrange)),
              ],
            ),
          ),
          SizedBox(width: Responsive.w(8)),
          if (!item.available)
            Text('उपलब्ध नाही', style: AppTextStyles.caption.copyWith(color: AppColors.error))
          else
            quantity == 0 ? _addButton() : _stepper(),
        ],
      ),
    );
  }

  Widget _addButton() => OutlinedButton(
        onPressed: onAdd,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Responsive.w(12))),
        ),
        child: Text('जोडा',
            style: AppTextStyles.label.copyWith(color: AppColors.primaryGreen)),
      );

  Widget _stepper() => Container(
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(Responsive.w(12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _stepBtn(Icons.remove_rounded, onRemove),
            Text('$quantity',
                style: AppTextStyles.button.copyWith(fontSize: Responsive.sp(15))),
            _stepBtn(Icons.add_rounded, onAdd),
          ],
        ),
      );

  Widget _stepBtn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.w(12)),
        child: Padding(
          padding: EdgeInsets.all(Responsive.w(8)),
          child: Icon(icon, color: AppColors.white, size: Responsive.w(20)),
        ),
      );
}
