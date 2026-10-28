import 'package:get/get.dart';
import '../core/utils/app_snackbar.dart';
import '../model/misc_models.dart';
import '../repository/common_repository.dart';

/// In-app notifications – same for every role.
class NotificationController extends GetxController {
  final CommonRepository _repo = Get.find<CommonRepository>();

  final RxList<NotificationModel> items = <NotificationModel>[].obs;
  final RxInt unread = 0.obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnInt errorCode = RxnInt();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    errorCode.value = null;
    final res = await _repo.notifications();
    if (res.isSuccess) {
      items.assignAll(res.data!);
      unread.value = res.meta['unread'] is num
          ? (res.meta['unread'] as num).toInt()
          : items.where((e) => !e.isRead).length;
    } else {
      items.clear();
      errorMessage.value = res.message;
      errorCode.value = res.code;
    }
    isLoading.value = false;
  }

  Future<void> markRead(NotificationModel n) async {
    if (n.isRead) return;
    final res = await _repo.markRead(n.id);
    if (res.isSuccess) {
      final i = items.indexWhere((e) => e.id == n.id);
      if (i != -1) items[i] = n.copyWith(isRead: true);
      if (unread.value > 0) unread.value--;
    } else {
      AppSnackbar.error(res.message, code: res.code);
    }
  }

  Future<void> markAllRead() async {
    final res = await _repo.markAllRead();
    if (res.isSuccess) {
      items.assignAll(items.map((e) => e.copyWith(isRead: true)));
      unread.value = 0;
    } else {
      AppSnackbar.error(res.message, code: res.code);
    }
  }
}
