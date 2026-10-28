import 'package:get/get.dart';
import '../../model/menu_item.dart';
import '../../model/mess_model.dart';
import '../../repository/customer_repository.dart';

/// One mess + its menu. Opened with `arguments: MessModel`.
class MessDetailController extends GetxController {
  final CustomerRepository _repo = Get.find<CustomerRepository>();

  late final MessModel mess = Get.arguments as MessModel;

  final RxList<MenuItem> items = <MenuItem>[].obs;
  final Rxn<MessModel> fullMess = Rxn<MessModel>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnInt errorCode = RxnInt();

  /// header data – detailed response if loaded, otherwise the list item
  MessModel get header => fullMess.value ?? mess;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    errorCode.value = null;

    final res = await _repo.messDetail(mess.id);
    if (res.isSuccess) {
      final d = res.data!;
      items.assignAll(d.menu);
      // keep the list item's id (it is the mavshiId used for ordering)
      fullMess.value = d.mess.id.isEmpty
          ? mess
          : MessModel(
              id: mess.id,
              messName: d.mess.messName.isEmpty ? mess.messName : d.mess.messName,
              ownerName: d.mess.ownerName.isEmpty ? mess.ownerName : d.mess.ownerName,
              areaName: d.mess.areaName.isEmpty ? mess.areaName : d.mess.areaName,
              pincode: d.mess.pincode.isEmpty ? mess.pincode : d.mess.pincode,
              address: d.mess.address.isEmpty ? mess.address : d.mess.address,
              experienceYears: d.mess.experienceYears == 0
                  ? mess.experienceYears
                  : d.mess.experienceYears,
            );
    } else {
      items.clear();
      errorMessage.value = res.message;
      errorCode.value = res.code;
    }
    isLoading.value = false;
  }
}
