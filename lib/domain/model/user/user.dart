import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live812/domain/model/json_data.dart';
import 'package:live812/utils/consts/consts.dart';

class UserModel extends ChangeNotifier {
  dynamic _json;
  // id は APIやり取り用、symbolは表示する第二の名前、とする。
  String _id;
  String _symbol;  // userId というのは紛らわしいので、アプリ側ではシンボルと呼ぶことにする
  String _emailAddress;
  String _nickname;
  String _token;
  String _profile;
  int _point;
  int _monthlyGiftPoint;
  int _monthlyLiveTime;
  bool _isLiver = false;
  bool _isBroadcasting;
  List<String> _followCsv;
  String _registrationId;  // Firebaseトークン
  int _rank;
  bool _isIAPRecovery;
  bool _isBeginner = false;
  /// イベントが作成可能かどうか.
  bool _enableEvent = false;
  int _liveWidth = Consts.AGORA_LIVE_WIDTH;
  int _liveHeight = Consts.AGORA_LIVE_HEIGHT;
  int _liveFrameRate = Consts.AGORA_LIVE_FRAMERATE;
  int _liveBitrate = Consts.AGORA_LIVE_BITRATE;

  dynamic get json => _json;
  String get id => _id;
  String get symbol => _symbol;
  String get emailAddress => _emailAddress;
  String get nickname => _nickname;
  String get token => _token;
  bool get isLiver => _isLiver;
  String get profile => _profile;
  int get point => _point;
  int get monthlyGiftPoint => _monthlyGiftPoint;
  int get monthlyLiveTime => _monthlyLiveTime;
  List<String> get followCsv => _followCsv;
  String get registrationId => _registrationId;
  int get rank => _rank;
  bool get isBroadcasting => _isBroadcasting;
  bool get isIAPRecovery => _isIAPRecovery;
  bool get isBeginner => _isBeginner ?? false;
  bool get enableEvent => _enableEvent ?? false;
  int get liveWidth => _liveWidth;
  int get liveHeight => _liveHeight;
  int get liveFrameRate => _liveFrameRate;
  int get liveBitrate => _liveBitrate;

  String get imgThumbUrl => _json['img_thumb_url'];
  String get deliveryName => _json['delivery_name'];
  String get deliveryAddr => _json['delivery_addr'];
  String get deliveryBuild => _json['delivery_build'];
  String get deliveryPostalCode => _json['delivery_postal_code'];
  String get deliveryPhone => _json['delivery_phone'];

  UserModel();

  UserModel.fromJson(dynamic json) {
    readFromJson(json);
  }

  static List<UserModel> fromJsonList(jsonList) {
    return jsonList.map<UserModel>((obj) => UserModel.fromJson(obj)).toList();
  }

  void readFromJson(dynamic json) {
    _json = json;
    _token = json['token'];
    _id = json['id'];
    _symbol = json['user_id'];  // サーバ側ではuser_idだが紛らわしいので、アプリ側ではsymbolと呼ぶことにする。
    _emailAddress = json['mail'];
    _nickname = json['nickname'];
    _isLiver = json['is_liver'] == true;
    _profile = json['profile'];
    _point = json['point'] ?? _point ?? 0;
    _monthlyGiftPoint = json['monthly_gift_point'] ?? _monthlyGiftPoint ?? 0;
    _monthlyLiveTime = json['monthly_live_time'] ?? _monthlyLiveTime ?? 0;
    _followCsv = json['follow_csv']?.isNotEmpty == true ? json['follow_csv'].split(',') : [];
    _registrationId = json['registration_id'];
    _rank = json['rank'] != null ? int.tryParse(json['rank']) : null;
    _enableEvent = json['enable_event'] == true;

    notifyListeners();
  }

  void setBeginner(JsonData json) {
    if (json?.containsKey("is_beginner") ?? false) {
      _isBeginner = json.getByKey("is_beginner");
    }
  }

  void setEnableEvent(JsonData json) {
    if (json?.containsKey('enable_event') ?? false) {
      _enableEvent = json.getByKey('enable_event') == true;
    }
  }

  void setAgoraConfig(JsonData json)
  {
    _liveWidth = json.containsKey('live_width') ? json.getByKey('live_width') : Consts.AGORA_LIVE_WIDTH;
    _liveHeight = json.containsKey('live_height') ? json.getByKey('live_height') : Consts.AGORA_LIVE_HEIGHT;
    _liveFrameRate = json.containsKey('live_framerate') ? json.getByKey('live_framerate') : Consts.AGORA_LIVE_FRAMERATE;
    _liveBitrate = json.containsKey('live_bitrate') ? json.getByKey('live_bitrate') : Consts.AGORA_LIVE_BITRATE;
  }

  void setEmailAddress(String emailAddress) {
    if (_emailAddress != emailAddress) {
      _emailAddress = emailAddress;
      notifyListeners();
    }
  }

  void setNickname(String nickname) {
    if (_nickname != nickname) {
      _nickname = nickname;
      notifyListeners();
    }
  }

  void setSymbol(String symbol) {
    if (_symbol != symbol) {
      _symbol = symbol;
      notifyListeners();
    }
  }

  Future<UserModel> setToken(String token) async {
    if (_token != token) {
      _token = token;
      await FlutterSecureStorage().write(key: 'token', value: token);
      notifyListeners();
    }
    return Future.value(this);
  }

  void setId(String id) {
    if (_id != id) {
      _id = id;
      notifyListeners();
    }
  }

  void setUserId(String userId) {
    if (_symbol != userId) {
      _symbol = userId;
      notifyListeners();
    }
  }

  void setIsLiver(bool isLiver) {
    if (_isLiver != isLiver) {
      _isLiver = isLiver;
      notifyListeners();
    }
  }

  void setIsBroadcasting(bool isBroadcasting) {
    if (_isBroadcasting != isBroadcasting) {
      _isBroadcasting = isBroadcasting;
      notifyListeners();
    }
  }

  void setProfile(String profile) {
    if (_profile != profile) {
      _profile = profile;
      notifyListeners();
    }
  }

  void setPoint(int point) {
    if (_point != point) {
      _point = point;
      notifyListeners();
    }
  }

  void setMonthlyGiftPoint(int monthlyGiftPoint) {
    if (_monthlyGiftPoint != monthlyGiftPoint) {
      _monthlyGiftPoint = monthlyGiftPoint;
      notifyListeners();
    }
  }

  void setMonthlyLiveTime(int monthlyLiveTime) {
    if (_monthlyLiveTime != monthlyLiveTime) {
      _monthlyLiveTime = monthlyLiveTime;
      notifyListeners();
    }
  }

  // 配送先情報
  void setDeliveryInfo(String deliveryName, String deliveryPostalCode, String deliveryAddr, String deliveryBuild, String deliveryPhone) {
    if (_json != null) {
      _json['delivery_name'] = deliveryName;
      _json['delivery_addr'] = deliveryAddr;
      _json['delivery_build'] = deliveryBuild;
      _json['delivery_postal_code'] = deliveryPostalCode;
      _json['delivery_phone'] = deliveryPhone;
    }
    notifyListeners();
  }

  void setRegistrationId(String registrationId) {
    if (_registrationId != registrationId) {
      _registrationId = registrationId;
      notifyListeners();
    }
  }

  /// 保留レシートを処理するフラグ.
  void setIAPRecovery(bool iapRecovery) {
    if (iapRecovery != null) {
      _isIAPRecovery = iapRecovery;
    }
  }

  void addFollow(String userId) {
    if (_followCsv == null) {
      _followCsv = [userId];
    } else if (!_followCsv.contains(userId)) {
      _followCsv.add(userId);
    }
  }

  void removeFollow(String userId) {
    _followCsv?.remove(userId);
  }

  String toString() {
    return 'User{id=$_id, userId=$_symbol, email=$_emailAddress, nickname=$_nickname, token=$_token, isLiver=$_isLiver, isBroadcasting=$_isBroadcasting point=$_point, monthlyGiftPoint=$_monthlyGiftPoint, monthlyLiveTime=$_monthlyLiveTime, profile=$_profile, rank=$_rank}';
  }

  static const _KEY_ID = 'id';
  static const _KEY_SYMBOL = 'userSymbol';
  static const _KEY_EMAIL = 'email';
  static const _KEY_NICKNAME = 'nickname';
  static const _KEY_TOKEN = 'token';
  static const _KEY_IS_LIVER = 'isLiver';
  static const _KEY_IS_BROADCASTING = 'isBroadcasting';
  static const _POINT = 'point';
  static const _MONTHLY_GIFT_POINT = 'monthlyGiftPoint';
  static const _MONTHLY_LIVE_TIME = 'monthlyLiveTime';
  static const _PROFILE = 'profile';
  static const _REGISTRATION_ID = 'registrationId';

  static const List<String> kKeyTable = [
    _KEY_ID,
    _KEY_SYMBOL,
    _KEY_EMAIL,
    _KEY_NICKNAME,
    _KEY_TOKEN,
    _KEY_IS_LIVER,
    _KEY_IS_BROADCASTING,
    _POINT,
    _MONTHLY_GIFT_POINT,
    _MONTHLY_LIVE_TIME,
    _PROFILE,
    _REGISTRATION_ID,
  ];

  Future<bool> saveToStorage() async {
    final table = {
      _KEY_ID: _id,
      _KEY_SYMBOL: _symbol,
      _KEY_EMAIL: _emailAddress,
      _KEY_NICKNAME: _nickname,
      _KEY_TOKEN: _token,
      _KEY_IS_LIVER: _isLiver,
      _KEY_IS_BROADCASTING: _isBroadcasting,
      _POINT: _point,
      _MONTHLY_GIFT_POINT: _monthlyGiftPoint,
      _MONTHLY_LIVE_TIME: _monthlyLiveTime,
      _PROFILE: _profile,
      _REGISTRATION_ID: _registrationId,
    };
    await Future.wait(kKeyTable.map((key) async {
      if (table[key] == null)
        await FlutterSecureStorage().delete(key: key);
      else
        await FlutterSecureStorage().write(key: key, value: table[key].toString());
    }));
    return true;
  }

  Future<bool> loadFromStorage() async {
    final results = Map<String, String>();
    await Future.wait(
        kKeyTable.map((key) async {
          results[key] = await FlutterSecureStorage().read(key: key);
        }).toList()
    );
    _id = results[_KEY_ID];
    _symbol = results[_KEY_SYMBOL];
    _emailAddress = results[_KEY_EMAIL];
    _nickname = results[_KEY_NICKNAME];
    _token = results[_KEY_TOKEN];
    _isLiver = results[_KEY_IS_LIVER] == true.toString();
    _isBroadcasting = results[_KEY_IS_BROADCASTING] == true.toString();
    _point = int.parse(results[_POINT] ?? "0");
    _monthlyGiftPoint = int.parse(results[_MONTHLY_GIFT_POINT] ?? "0");
    _monthlyLiveTime = int.parse(results[_MONTHLY_LIVE_TIME] ?? "0");
    _profile = results[_PROFILE];
    _registrationId = results[_REGISTRATION_ID];
    notifyListeners();
    return true;
  }

  Future<bool> deleteFromStorage() async {
    await Future.wait(kKeyTable.map(
            (key) => FlutterSecureStorage().delete(key: key)));

    _id = null;
    _symbol = null;
    _emailAddress = null;
    _nickname = null;
    _token = null;
    _isLiver = false;
    _isBroadcasting = false;
    _point = null;
    _monthlyGiftPoint = null;
    _monthlyLiveTime = null;
    _profile = null;
    _registrationId = null;
    return true;
  }
}
