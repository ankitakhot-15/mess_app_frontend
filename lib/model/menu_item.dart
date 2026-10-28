import '../core/constants/app_enums.dart';
import '../core/utils/json_helper.dart';

class MenuItem {
  final String id;
  final String name;
  final String description;
  final String mealType;
  final String foodType;
  final num price; // DAY price
  final num? weeklyPrice;
  final num? monthlyPrice;
  final bool available;
  final String imageUrl;

  /// Prices sent by the customer API: {DAY, WEEK, MONTH}
  final Map<String, num> _prices;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.mealType,
    required this.foodType,
    required this.price,
    this.weeklyPrice,
    this.monthlyPrice,
    required this.available,
    required this.imageUrl,
    Map<String, num> prices = const {},
  }) : _prices = prices;

  bool get isVeg => foodType == 'VEG';

  /// Price for the selected plan. Missing weekly / monthly price
  /// defaults to price x 7 / x 30 (same rule as the backend).
  num priceFor(OrderPlan plan) {
    final fromApi = _prices[plan.value];
    if (fromApi != null) return fromApi;
    switch (plan) {
      case OrderPlan.day:
        return price;
      case OrderPlan.week:
        return weeklyPrice ?? price * 7;
      case OrderPlan.month:
        return monthlyPrice ?? price * 30;
    }
  }

  factory MenuItem.fromJson(Map<String, dynamic> j) {
    final p = J.map(j['prices']);
    final prices = <String, num>{
      for (final e in p.entries) e.key.toUpperCase(): J.number(e.value),
    };
    return MenuItem(
      id: J.id(j),
      name: J.str(j['name']),
      description: J.str(j['description']),
      mealType: J.str(j['mealType']),
      foodType: J.str(j['foodType'], 'VEG'),
      price: J.number(j['price'] ?? prices['DAY']),
      weeklyPrice: j['weeklyPrice'] == null ? null : J.number(j['weeklyPrice']),
      monthlyPrice: j['monthlyPrice'] == null ? null : J.number(j['monthlyPrice']),
      available: J.boolean(j['available'], true),
      imageUrl: J.firstStr(j, ['imageUrl', 'image']),
      prices: prices,
    );
  }
}
