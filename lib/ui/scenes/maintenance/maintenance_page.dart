import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:live812/domain/model/json_data.dart';
import 'package:live812/domain/services/NetworkService.dart';
import 'package:live812/ui/scenes/maintenance/update_required_page.dart';
import 'package:live812/ui/scenes/splash/splash_screen.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/version_util.dart';
import 'package:package_info/package_info.dart';

class MaintenancePage extends StatefulWidget {
  final String message;
  final String imgUrl;

  MaintenancePage(this.message, this.imgUrl);

  @override
  _MaintenancePageState createState() => _MaintenancePageState();

  static Future<bool> checkMaintenanceMode(BuildContext context) async {
    final url = Injector.getInjector().get<String>(key: Consts.KEY_MAINTENANCE_URL);
    final result = await NetworkService.loadJson(url);
    return await result.match(
      ok: (JsonData json) async {
        if (json.getByKey('maintenance') == true) {
          final message = json.getByKey('message');
          final imgUrl = json.getByKey('img_url');
          _gotoMaintenancePage(context, message, imgUrl);
          return true;
        }

        final requiredVersion = json.getByKey('ver');
        if (requiredVersion != null) {
          PackageInfo packageInfo = await PackageInfo.fromPlatform();
          final appVersion = packageInfo.version;
          if (VersionUtil.updateRequired(
                  requiredVersion: requiredVersion, appVersion: appVersion)) {
            _gotoUpdateRequiredPage(context, requiredVersion, appVersion);
            return true;
          }
        }
        return false;
      },
      err: (error) {
        debugPrint(error?.toString());
        return false;
      },
    );
  }

  static void _gotoMaintenancePage(BuildContext context, String message, String imgUrl) {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (context, _anim1, _anim2) => MaintenancePage(message, imgUrl)));
  }

  static void _gotoUpdateRequiredPage(BuildContext context, String requiredVersion, String appVersion) {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (context, _anim1, _anim2) => UpdateRequiredPage(requiredVersion, appVersion)));
  }
}

class _MaintenancePageState extends State<MaintenancePage> with WidgetsBindingObserver {
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            return Future.value(false);  // バックキーを無効に
          },
          child: DefaultTextStyle(
            style: TextStyle(color: Colors.black, fontSize: 16),
            child: Column(
              children: <Widget>[
                widget.imgUrl == null ? Container() : Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Image.network(
                    widget.imgUrl,
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Text(widget.message ?? 'メンテナンス中です'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // アプリが再アクティブになった際に再度チェックし
      // メンテナンスモードが解けていたらスプラッシュ画面に遷移する
      if (!await MaintenancePage.checkMaintenanceMode(context))
        _gotoSplashPage(context);
    }
  }

  void _gotoSplashPage(BuildContext context) async {
    Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
            pageBuilder: (context, _anim1, _anim2) => SplashScreen()),
        (_) => false);
  }
}
