import 'package:flutter_test/flutter_test.dart';
import 'package:mayechi_chav/model/order_model.dart';

void main() {
  group('OrderPreview.fromJson', () {
    test('reads prices from the API pricing object', () {
      final preview = OrderPreview.fromJson({
        'items': [],
        'pricing': {'subtotal': 80, 'deliveryCharge': 20, 'total': 100},
      });

      expect(preview.subtotal, 80);
      expect(preview.deliveryCharge, 20);
      expect(preview.total, 100);
    });
  });

  group('OrderModel.fromJson', () {
    test('reads prices from the order pricing object', () {
      final order = OrderModel.fromJson({
        'id': 'order-id',
        'pricing': {'subtotal': 80, 'deliveryCharge': 20, 'total': 100},
      });

      expect(order.subtotal, 80);
      expect(order.deliveryCharge, 20);
      expect(order.total, 100);
    });

    test('continues reading legacy top-level price fields', () {
      final order = OrderModel.fromJson({
        'subtotal': 80,
        'deliveryCharge': 20,
        'total': 100,
      });

      expect(order.subtotal, 80);
      expect(order.deliveryCharge, 20);
      expect(order.total, 100);
    });
  });
}
