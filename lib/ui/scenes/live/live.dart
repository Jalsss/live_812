import 'package:flutter/material.dart';
import 'package:live812/domain/model/live/broadcast_info.dart';
import 'package:live812/ui/scenes/live/live_form.dart';
import 'package:live812/ui/scenes/live/live_stream.dart';
import 'package:live812/utils/route/fade_route.dart';

class LivePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LiveFormPage(
      callback: ({
        BroadcastInfo broadcastInfo,
        CameraType cameraType,
        bool isPortrait,
        bool enableBeautification,
      }) {
        Navigator.pushReplacement(
          context,
          FadeRoute(
            builder: (context) => LiveStreamPage(
              broadcastInfo: broadcastInfo,
              liveId: broadcastInfo.liveId,
              cameraType: cameraType,
              isPortrait: isPortrait,
              enableBeautification: enableBeautification,
            ),
          ),
        );
      },
    );
  }
}
