import 'package:live812/ui/scenes/home/bottom_navigation.dart';
import 'package:live812/ui/scenes/login/login.dart';
import 'package:live812/ui/scenes/settings/contact_page.dart';
import 'package:live812/ui/scenes/settings/friend_share_page.dart';
import 'package:live812/ui/scenes/settings/logout_page.dart';
import 'package:live812/ui/scenes/settings/quit_service_page.dart';
import 'package:live812/ui/scenes/settings/setting_block_page.dart';
import 'package:live812/ui/scenes/settings/setting_email_change.dart';
import 'package:live812/ui/scenes/settings/setting_nickname_change.dart';
import 'package:live812/ui/scenes/settings/setting_page.dart';
import 'package:live812/ui/scenes/settings/setting_password_change.dart';
import 'package:live812/ui/scenes/settings/setting_specified_commercial.dart';
import 'package:live812/ui/scenes/shop/shop_page.dart';
import 'package:live812/ui/scenes/splash/walk_through.dart';
import 'package:live812/ui/scenes/user/charge_page.dart';
import 'package:live812/ui/scenes/user/coin_history_page.dart';
import 'package:live812/ui/scenes/user/following_page.dart';
import 'package:live812/ui/scenes/user/history_purchase_page.dart';
import 'package:live812/ui/scenes/user/liver/liver_history_purchase_page.dart';
import 'package:live812/ui/scenes/user/notice_page.dart';
import 'package:live812/ui/scenes/user/product_sale_page.dart';

final routes = {
  '/bottom_nav': (context) => BottomNav(),
  '/login': (context) => LoginPage(),
  '/walk_through': (context) => WalkThrough(),
  '/mypage/notice': (context) => NoticePage(),
  '/mypage/coin/history': (context) => CoinHistoryPage(),
  '/mypage/coin/charge': (context) => ChargePage(),
  '/mypage/following': (context) => FollowingPage(),
  '/mypage/products': (context) => ProductSalePage(),
  '/mypage/draft': (context) => ProductSalePage(isDraft: true),
  '/mypage/sales': (context) => LiverHistoryPurchasePage(isTrading: false),
  '/mypage/sales/trading': (context) =>
      LiverHistoryPurchasePage(isTrading: true),
  '/mypage/purchases': (context) => HistoryPurchasePage(isTrading: false),
  '/mypage/purchases/trading': (context) =>
      HistoryPurchasePage(isTrading: true),
  '/setting': (context) => SettingPage(),
  '/setting/nickname': (context) => SettingNicknameChangePage(),
  '/setting/email': (context) => SettingEmailChangePage(),
  '/setting/password': (context) => SettingPasswordChangePage(),
  '/setting/block': (context) => SettingBlockPage(),
  '/setting/share': (context) => FriendSharePage(),
  '/setting/specified_commercial': (context) =>
      SettingSpecifiedCommercialPage(),
  '/setting/contact': (context) => ContactPage(),
  '/setting/logout': (context) => LogoutPage(),
  '/setting/quit_service': (context) => QuitServicePage(),
  '/shop': (context) => ShopPage(),
};
