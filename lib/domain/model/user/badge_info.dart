import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:live812/domain/model/json_data.dart';
import 'package:live812/domain/model/user/notice.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/repository/persistent_repository.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/services/api_path.dart';
import 'package:live812/utils/on_memory_cache.dart';
import 'package:provider/provider.dart';

class BadgeInfo extends ChangeNotifier {
  bool _info = false;     // ニュース
  bool _purchase = false; // 購入
  bool _sales = false;    // 販売
  bool _unread = false;   // 自分宛未読
  bool _chatPurchase = false;     // 購入取引中のチャット
  bool _pastChatPurchase = false; // 購入済のチャット
  bool _chatSales = false;        // 販売取引中のチャット
  bool _pastChatSales = false;    // 販売済みのチャット

  bool get myPageTab => _info || _purchase || _sales || _unread || chat;
  bool get myPageBell => _info || _unread;
  bool get info => _info;
  bool get purchase => _purchase;
  bool get sales => _sales;
  bool get unread => _unread;
  bool get chat => _chatPurchase || _pastChatPurchase || _chatSales || _pastChatSales;
  bool get chatPurchase => _chatPurchase;
  bool get pastChatPurchase => _pastChatPurchase;
  bool get chatSales => _chatSales;
  bool get pastChatSales => _pastChatSales;

  set info(value) {
    _info = value;
    notifyListeners();
  }

  set purchase(value) {
    _purchase = value;
    if (value)
      _unread = true;  // 購入した場合、未読も有効になるはず
    notifyListeners();
  }

  set unread(value) {
    _unread = value;
    notifyListeners();
  }

  Future<void> requestMyInfoBadge(BuildContext context, {bool force}) async {
    final response = await OnMemoryCache.fetch(
        ApiPath.mypage, Duration(minutes: 1), () async {
      final service = BackendService(context);
      final response = await service.getMypage();
      return response?.result == true ? response : null;
    }, force: true);
    applyMyPageResponse(response);
    if ((response?.result ?? false) == true) {
      final userModel = Provider.of<UserModel>(context, listen: false);
      userModel.setIAPRecovery(response?.data?.getByKey("iap_recovery"));
      userModel.setBeginner(response);
      userModel.setAgoraConfig(response);
    }
  }

  void applyMyPageResponse(JsonData response) async {
    if (response?.result == true) {
      final data = response.data;
      _purchase = data.getByKey('badge_purchase') == true;
      _sales = data.getByKey('badge_sales') == true;
      _unread = data.getByKey('badge_unread') == true;
      _chatPurchase = data.getByKey('badge_chat_purchase') == true;
      _pastChatPurchase = data.getByKey('badge_past_chat_purchase') == true;
      _chatSales = data.getByKey('badge_chat_sales') == true;
      _pastChatSales = data.getByKey('badge_past_chat_sales') == true;
      notifyListeners();
    }
  }

  Future<List<NoticeModel>> requestNoticeInfo(BuildContext context, int size) async {
    final service = BackendService(context);
    final response = await service.getInfo(size: size, offset: 0);
    if (response?.result != true)
      return null;

    final data = response.getData();
    List<NoticeModel> notices = [];
    for (final info in data) {
      final notice = NoticeModel.fromJson(info);
      notices.add(notice);
    }

    // 既読かどうかを取得
    final repo = Injector.getInjector().get<PersistentRepository>();
    final results = await Future.wait(notices.map((notice) => repo.isNoticeRead(notice.id)));
    final futures = List<Future>();
    for (var i = 0; i < notices.length; ++i) {
      final notice = notices[i];
      if (results[i] != null) {
        notice.read = results[i] == true;
      } else {
        futures.add(repo.insertNotice(notice));
      }
    }
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
    bool info = notices.any((n) => !n.read);
    if (_info != info) {
      _info = info;
      notifyListeners();
    }

    return notices;
  }

  @override
  String toString() {
    return 'BadgeInfo{info=$_info, purchase=$_purchase, sales=$_sales}';
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
