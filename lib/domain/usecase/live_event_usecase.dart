import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:live812/domain/model/live/live_event.dart';
import 'package:live812/domain/model/live/live_event_member.dart';
import 'package:live812/domain/model/live/live_event_prize.dart';
import 'package:live812/domain/model/live/live_event_ranking.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/utils/consts/language.dart';

class LiveEventUseCase {
  LiveEventUseCase._();

  /// イベント開催中一覧取得.
  static Future<List<LiveEvent>> requestOpenLiveEvent(
    BuildContext context,
  ) async {
    final service = BackendService(context);
    final response = await service.getEventListLive();
    if (!response.result) {
      throw HttpException(Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER);
    }
    List<dynamic> data = response.getData();
    return data.map((e) => LiveEvent.fromJson(e)).toList();
  }

  /// イベント開催予定一覧取得.
  static Future<List<LiveEvent>> requestScheduleLiveEvent(
    BuildContext context,
  ) async {
    final service = BackendService(context);
    final response = await service.getEventListPlaned();
    if (!response.result) {
      throw HttpException(Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER);
    }
    List<dynamic> data = response.getData();
    return data.map((e) => LiveEvent.fromJson(e)).toList();
  }

  /// イベント終了一覧取得.
  static Future<List<LiveEvent>> requestClosedLiveEvent(
    BuildContext context,
  ) async {
    final service = BackendService(context);
    final response = await service.getEventListFinished();
    if (!response.result) {
      throw HttpException(Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER);
    }
    List<dynamic> data = response.getData();
    return data.map((e) => LiveEvent.fromJson(e)).toList();
  }

  /// イベント参加募集一覧取得.
  static Future<List<LiveEvent>> requestWantedLiveEvent(
    BuildContext context,
  ) async {
    final service = BackendService(context);
    final response = await service.getEventListInvited();
    if (!response.result) {
      throw HttpException(Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER);
    }
    List<dynamic> data = response.getData();
    return data.map((e) => LiveEvent.fromJson(e)).toList();
  }

  /// Webトークンを取得.
  static Future<String> requestWebToken(BuildContext context) async {
    final service = BackendService(context);
    final request = await service.getWebToken();
    if (!request.result) {
      throw HttpException(Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER);
    }
    return request.getData()['token'] as String;
  }

  /// イベント情報取得.
  static Future<LiveEvent> requestLiveEventOverView(
    BuildContext context,
    String eventId,
  ) async {
    final service = BackendService(context);
    final response = await service.getEventOverView(id: eventId);
    if (!response.result) {
      throw HttpException(Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER);
    }
    return LiveEvent.fromJson(response.getData());
  }

  /// イベントランキング情報取得.
  static Future<LiveEventRanking> requestLiveEventRanking(
    BuildContext context,
    String eventId,
  ) async {
    final service = BackendService(context);
    final response = await service.getEventRanking(id: eventId);
    if (!response.result) {
      throw HttpException(Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER);
    }
    return LiveEventRanking.fromJson(response.getData());
  }

  /// イベントプライズ情報取得.
  static Future<LiveEventPrize> requestLiveEventPrize(
    BuildContext context,
    String eventId,
  ) async {
    final service = BackendService(context);
    final response = await service.getEventPrize(id: eventId);
    if (!response.result) {
      throw HttpException(Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER);
    }
    return LiveEventPrize.fromJson(response.getData());
  }

  /// イベント参加者一覧取得.
  static Future<List<LiveEventMember>> requestLiveEventMember(
    BuildContext context,
    String eventId,
  ) async {
    final service = BackendService(context);
    final response = await service.getEventMember(id: eventId);
    if (!response.result) {
      throw HttpException(Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER);
    }
    List<dynamic> data = response.getData();
    return data.map((e) => LiveEventMember.fromJson(e)).toList();
  }

  /// イベント参加
  static Future<bool> postLiveEventEntry(
    BuildContext context,
    String eventId,
  ) async {
    final service = BackendService(context);
    final response = await service.postEventEntry(id: eventId);
    if (!response.result) {
      if (response.containsKey('message')) {
        throw HttpException(response.getByKey('message'));
      } else {
        throw HttpException(Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER);
      }
    }
    return true;
  }

  /// イベント参加解除.
  static Future<bool> deleteLiveEventEntry(
    BuildContext context,
    String eventId,
  ) async {
    final service = BackendService(context);
    final response = await service.deleteEventEntry(id: eventId);
    if (!response.result) {
      if (response.containsKey('message')) {
        throw HttpException(response.getByKey('message'));
      } else {
        throw HttpException(Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER);
      }
    }
    return true;
  }

  /// イベントフォロー.
  static Future<bool> postLiveEventFollow(
    BuildContext context,
    String eventId,
  ) async {
    final service = BackendService(context);
    final response = await service.postEventFollow(id: eventId);
    if (!response.result) {
      if (response.containsKey('message')) {
        throw HttpException(response.getByKey('message'));
      } else {
        throw HttpException(Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER);
      }
    }
    return true;
  }

  /// イベントフォロー解除.
  static Future<bool> deleteLiveEventFollow(
    BuildContext context,
    String eventId,
  ) async {
    final service = BackendService(context);
    final response = await service.deleteEventFollow(id: eventId);
    if (!response.result) {
      if (response.containsKey('message')) {
        throw HttpException(response.getByKey('message'));
      } else {
        throw HttpException(Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER);
      }
    }
    return true;
  }
}
