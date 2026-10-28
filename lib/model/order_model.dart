import '../core/utils/json_helper.dart';

class OrderItemModel {
  final String name;
  final num price;
  final int quantity;

  const OrderItemModel({required this.name, required this.price, required this.quantity});

  factory OrderItemModel.fromJson(Map<String, dynamic> j) {
    final menu = J.map(j['menuItem']);
    return OrderItemModel(
      name: J.firstStr(j, ['name', 'menuItemName'], J.str(menu['name'])),
      price: J.number(j['price'] ?? j['unitPrice'] ?? menu['price']),
      quantity: J.integer(j['quantity'], 1),
    );
  }
}

/// One order – same model for customer, mavshi and delivery boy screens.
class OrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final String plan;
  final String startDate;
  final List<OrderItemModel> items;
  final num subtotal;
  final num deliveryCharge;
  final num total;
  final String paymentMethod;
  final String paymentStatus;
  final String address;
  final String pincode;
  final String areaName;
  final String notes;
  final String rejectionReason;
  final String refundInfo;
  final String etaText;
  final String messName;
  final String customerName;
  final String customerMobile;
  final String deliveryBoyName;
  final String createdAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.plan,
    required this.startDate,
    required this.items,
    required this.subtotal,
    required this.deliveryCharge,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.address,
    required this.pincode,
    required this.areaName,
    required this.notes,
    required this.rejectionReason,
    required this.refundInfo,
    required this.etaText,
    required this.messName,
    required this.customerName,
    required this.customerMobile,
    required this.deliveryBoyName,
    required this.createdAt,
  });

  bool get isCod => paymentMethod == 'COD';
  String get shortId => orderNumber.isNotEmpty
      ? orderNumber
      : (id.length > 6 ? id.substring(id.length - 6).toUpperCase() : id);

  factory OrderModel.fromJson(Map<String, dynamic> j) {
    // delivery can be {address, pincode, areaName} or flat fields
    final d = j['delivery'] is Map
        ? J.map(j['delivery'])
        : (j['deliveryAddress'] is Map ? J.map(j['deliveryAddress']) : <String, dynamic>{});
    final pricing = J.map(j['pricing']);
    final mavshi = J.map(j['mavshi']);
    final customer = J.map(j['customer']);
    final boy = J.map(j['deliveryBoy']);
    final refund = J.map(j['refund']);

    String refundInfo = '';
    if (refund.isNotEmpty) {
      final st = J.firstStr(refund, ['status']);
      final amt = refund['amount'];
      refundInfo = [if (st.isNotEmpty) st, if (amt != null) '₹$amt'].join(' • ');
    } else if (j['refundStatus'] != null) {
      refundInfo = J.str(j['refundStatus']);
    }

    return OrderModel(
      id: J.id(j),
      orderNumber: J.firstStr(j, ['orderNumber', 'orderNo']),
      status: J.str(j['status'], 'PLACED'),
      plan: J.str(j['plan']),
      startDate: J.str(j['startDate']),
      items: J.list(j['items']).map(OrderItemModel.fromJson).toList(),
      subtotal: J.number(j['subtotal'] ?? j['itemsTotal'] ?? pricing['subtotal']),
      deliveryCharge: J.number(j['deliveryCharge'] ?? pricing['deliveryCharge']),
      total: J.number(j['total'] ?? j['totalAmount'] ?? pricing['total']),
      paymentMethod: J.str(j['paymentMethod']),
      paymentStatus: J.str(j['paymentStatus']),
      address: J.firstStr(d, ['address'], j['deliveryAddress'] is String ? J.str(j['deliveryAddress']) : ''),
      pincode: J.firstStr(d, ['pincode'], J.str(j['pincode'])),
      areaName: J.firstStr(d, ['areaName'], J.str(j['areaName'])),
      notes: J.str(j['notes']),
      rejectionReason: J.firstStr(j, ['rejectionReason', 'rejectReason']),
      refundInfo: refundInfo,
      etaText: J.firstStr(j, ['etaMessage', 'eta']),
      messName: J.firstStr(mavshi, ['messName'], J.str(j['messName'])),
      customerName: J.firstStr(customer, ['fullName'], J.str(j['customerName'])),
      customerMobile: J.firstStr(customer, ['mobile'], J.str(j['customerMobile'])),
      deliveryBoyName: J.firstStr(boy, ['fullName'], J.str(j['deliveryBoyName'])),
      createdAt: J.str(j['createdAt']),
    );
  }
}

/// `POST /customer/orders/preview`
class OrderPreview {
  final num subtotal;
  final num deliveryCharge;
  final num total;

  const OrderPreview({required this.subtotal, required this.deliveryCharge, required this.total});

  factory OrderPreview.fromJson(Map<String, dynamic> j) {
    final p = j['pricing'] is Map
        ? J.map(j['pricing'])
        : (j['preview'] is Map ? J.map(j['preview']) : j);
    return OrderPreview(
      subtotal: J.number(p['subtotal']),
      deliveryCharge: J.number(p['deliveryCharge']),
      total: J.number(p['total']),
    );
  }
}

/// `razorpay` block returned for ONLINE orders.
class RazorpayInfo {
  final String keyId;
  final String orderId;
  final num amount;
  final String currency;

  const RazorpayInfo({
    required this.keyId,
    required this.orderId,
    required this.amount,
    required this.currency,
  });

  factory RazorpayInfo.fromJson(Map<String, dynamic> j) => RazorpayInfo(
        keyId: J.str(j['keyId']),
        orderId: J.str(j['orderId']),
        amount: J.number(j['amount']),
        currency: J.str(j['currency'], 'INR'),
      );
}

/// `POST /customer/orders` result.
class PlaceOrderResult {
  final OrderModel order;
  final RazorpayInfo? razorpay;

  const PlaceOrderResult({required this.order, this.razorpay});

  factory PlaceOrderResult.fromJson(Map<String, dynamic> j) {
    final orderMap = j['order'] is Map ? J.map(j['order']) : j;
    return PlaceOrderResult(
      order: OrderModel.fromJson(orderMap),
      razorpay: j['razorpay'] is Map ? RazorpayInfo.fromJson(J.map(j['razorpay'])) : null,
    );
  }
}

/// Body for preview + place order (same body for both).
class OrderRequest {
  final String mavshiId;
  final String plan;
  final String startDate;
  final Map<String, int> items; // menuItemId -> quantity
  final String address;
  final String pincode;
  final String areaName;
  final String paymentMethod;
  final String notes;

  const OrderRequest({
    required this.mavshiId,
    required this.plan,
    required this.startDate,
    required this.items,
    required this.address,
    required this.pincode,
    required this.areaName,
    required this.paymentMethod,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'mavshiId': mavshiId,
        'plan': plan,
        'startDate': startDate,
        'items': items.entries
            .map((e) => {'menuItemId': e.key, 'quantity': e.value})
            .toList(),
        'delivery': {
          'address': address,
          'pincode': pincode,
          if (areaName.isNotEmpty) 'areaName': areaName,
        },
        'paymentMethod': paymentMethod,
        if (notes.isNotEmpty) 'notes': notes,
      };
}
