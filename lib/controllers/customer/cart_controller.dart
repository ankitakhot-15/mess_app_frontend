import 'package:get/get.dart';
import '../../core/constants/app_enums.dart';
import '../../core/utils/app_dialogs.dart';
import '../../model/menu_item.dart';
import '../../model/mess_model.dart';

class CartLine {
  final MenuItem item;
  final int qty;
  const CartLine(this.item, this.qty);
}

/// Cart of ONE mess (an order belongs to one mavshi) + the selected plan.
class CartController extends GetxController {
  static const int _maxQty = 50;

  final Rxn<MessModel> mess = Rxn<MessModel>();
  final Rx<OrderPlan> plan = OrderPlan.day.obs;
  final RxMap<String, CartLine> lines = <String, CartLine>{}.obs;

  bool get isEmpty => lines.isEmpty;
  int get count => lines.values.fold(0, (s, l) => s + l.qty);
  int qty(String id) => lines[id]?.qty ?? 0;

  /// Local estimate only – the server price from `/orders/preview` is final.
  num get subtotal =>
      lines.values.fold<num>(0, (s, l) => s + l.item.priceFor(plan.value) * l.qty);

  Future<void> add(MessModel fromMess, MenuItem item) async {
    if (!item.available) return;
    if (lines.isNotEmpty && mess.value?.id != fromMess.id) {
      final ok = await AppDialogs.confirm(
        title: 'नवीन मेस निवडायची?',
        message: 'कार्टमध्ये दुसऱ्या मेसचे आयटम आहेत. ते काढून नवीन मेसमधून ऑर्डर करायची का?',
      );
      if (!ok) return;
      lines.clear();
    }
    mess.value = fromMess;
    final current = qty(item.id);
    if (current >= _maxQty) return;
    lines[item.id] = CartLine(item, current + 1);
  }

  void remove(String id) {
    final line = lines[id];
    if (line == null) return;
    if (line.qty <= 1) {
      lines.remove(id);
    } else {
      lines[id] = CartLine(line.item, line.qty - 1);
    }
    if (lines.isEmpty) mess.value = null;
  }

  void clear() {
    lines.clear();
    mess.value = null;
  }
}
