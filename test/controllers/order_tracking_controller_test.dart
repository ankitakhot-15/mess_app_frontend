import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mayechi_chav/controllers/customer/order_tracking_controller.dart';

void main() {
  test('reads rider location nested under deliveryBoy', () async {
    final controller = OrderTrackingController(
      'order-1',
      fetcher: () async => {
        'deliveryBoy': {
          'fullName': 'Delivery Partner',
          'mobile': '9999999999',
          'location': {
            'lat': 16.705,
            'lng': 74.2433,
            'areaName': 'Kolhapur',
          },
        },
        'status': 'OUT_FOR_DELIVERY',
      },
    );

    await controller.fetchLocation();

    expect(controller.rider.value, const LatLng(16.705, 74.2433));
    expect(controller.riderName.value, 'Delivery Partner');
    expect(controller.riderMobile.value, '9999999999');
    expect(controller.areaName.value, 'Kolhapur');
    expect(controller.status.value, 'OUT_FOR_DELIVERY');
    controller.onClose();
  });

  test('continues reading top-level rider coordinates', () async {
    final controller = OrderTrackingController(
      'order-2',
      fetcher: () async => {
        'lat': 16.7,
        'lng': 74.24,
        'areaName': 'Kolhapur',
      },
    );

    await controller.fetchLocation();

    expect(controller.rider.value, const LatLng(16.7, 74.24));
    expect(controller.areaName.value, 'Kolhapur');
    controller.onClose();
  });
}
