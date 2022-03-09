import Flutter
import UIKit

public class SwiftAgoraRtcRawdataPlugin: NSObject, FlutterPlugin, AgoraAudioFrameDelegate, AgoraVideoFrameDelegate {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "agora_rtc_rawdata", binaryMessenger: registrar.messenger())
        let instance = SwiftAgoraRtcRawdataPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    private var audioObserver: AgoraAudioFrameObserver?
    private var videoObserver: AgoraVideoFrameObserver?
    private var fuManager: FUManager?

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "registerAudioFrameObserver":
            if audioObserver == nil {
                audioObserver = AgoraAudioFrameObserver(engineHandle: call.arguments as! UInt)
            }
            audioObserver?.delegate = self
            audioObserver?.register()
            result(nil)
        case "unregisterAudioFrameObserver":
            if audioObserver != nil {
                audioObserver?.delegate = nil
                audioObserver?.unregisterAudioFrameObserver()
                audioObserver = nil
            }
            result(nil)
        case "registerVideoFrameObserver":
            if videoObserver == nil {
                videoObserver = AgoraVideoFrameObserver(engineHandle: call.arguments as! UInt)
                fuManager = FUManager.share()
            }
            videoObserver?.delegate = self
            videoObserver?.register()
            result(nil)
        case "unregisterVideoFrameObserver":
            if videoObserver != nil {
                fuManager?.destroyAllItems();
                videoObserver?.delegate = nil
                videoObserver?.unregisterVideoFrameObserver()
                videoObserver = nil
            }
            result(nil)
        case "enableFaceBeautification":
            fuManager?.enableFaceBeautification();
            result(nil)
        case "disableFaceBeautification":
            fuManager?.disableFaceBeautification();
            result(nil)
        case "setFaceBeautificationFilter":
            let arguments = call.arguments as! [NSString: Any]
            let filterName = arguments["filter_name"] as? String ?? ""
            let filterLevel = arguments["filter_level"] as? NSNumber ?? 0
            fuManager?.setFaceBeautificationFilter(filterName, filterLevel: filterLevel)
            result(nil)
        case "setFaceBeautificationSkinWhitening":
            let arguments = call.arguments as! [NSString: Any]
            let level = arguments["color_level"] as? NSNumber ?? 0.5
            fuManager?.setFaceBeautificationSkinWhitening(level)
            result(nil)
        case "setFaceBeautificationRuddy":
            let arguments = call.arguments as! [NSString: Any]
            let level = arguments["red_level"] as? NSNumber ?? 0.5
            fuManager?.setFaceBeautificationRuddy(level)
            result(nil)
        case "setFaceBeautificationBlur":
            let arguments = call.arguments as! [NSString: Any]
            let bl = arguments["blur_level"] as? NSNumber ?? 0.0
            let sd = arguments["skin_detect"] as? NSNumber ?? 0.0
            let nbs = arguments["nonskin_blur_scale"] as? NSNumber ?? 0.45
            let hb = arguments["heavy_blur"] as? NSNumber ?? 0.0
            let bbr = arguments["blur_blend_ratio"] as? NSNumber ?? 0.0
            fuManager?.setFaceBeautificationBlur(bl, skinDetect: sd, nonskinBlurScale: nbs, heavyBlur: hb, blurBlendRatio: bbr)
            result(nil)
        case "setFaceBeautificationEyeBrighten":
            let arguments = call.arguments as! [NSString: Any]
            let bright = arguments["eye_bright"] as? NSNumber ?? 0.0
            fuManager?.setFaceBeautificationEyeBrighten(bright)
            result(nil)
        case "setFaceBeautificationToothWhiten":
            let arguments = call.arguments as! [NSString: Any]
            let whiten = arguments["tooth_whiten"] as? NSNumber ?? 0.0
            fuManager?.setFaceBeautificationToothWhiten(whiten)
            result(nil)
        case "setFaceBeautificationFaceOutline":
            let arguments = call.arguments as! [NSString: Any]
            let fs = arguments["face_shape"] as? NSNumber ?? 3
            let fsl = arguments["face_shape_level"] as? NSNumber ?? 0
            let ee = arguments["eye_enlarging"] as? NSNumber ?? 0
            let ct = arguments["cheek_thinning"] as? NSNumber ?? 0
            let iF = arguments["intensity_forehead"] as? NSNumber ?? 0.5
            let iC = arguments["intensity_chin"] as? NSNumber ?? 0.5
            let iN = arguments["intensity_nose"] as? NSNumber ?? 0
            let iM = arguments["intensity_mouth"] as? NSNumber ?? 0.5
            fuManager?.setFaceBeautificationFaceOutline(fs, faceShapeLevel: fsl, eyeEnlarging: ee, cheekThinning: ct, intensityForehead: iF, intensityChin: iC, intensityNose: iN, intensityMouth: iM)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func onRecord(_: AgoraAudioFrame) -> Bool {
        return true
    }

    public func onPlaybackAudioFrame(_: AgoraAudioFrame) -> Bool {
        return true
    }

    public func onMixedAudioFrame(_: AgoraAudioFrame) -> Bool {
        return true
    }

    public func onPlaybackAudioFrame(beforeMixing _: AgoraAudioFrame, uid _: UInt) -> Bool {
        return true
    }

    public func onCapture(_ videoFrame: AgoraVideoFrame) -> Bool {
//        memset(videoFrame.uBuffer, 0, Int(videoFrame.uStride * videoFrame.height) / 2)
//        memset(videoFrame.vBuffer, 0, Int(videoFrame.vStride * videoFrame.height) / 2)
        fuManager?.processFrameWith(y: videoFrame.yBuffer, u: videoFrame.uBuffer, v: videoFrame.vBuffer, yStride: videoFrame.yStride, uStride: videoFrame.uStride, vStride: videoFrame.vStride, frameWidth: videoFrame.width, frameHeight: videoFrame.height)
        return true
    }

    public func onRenderVideoFrame(_ videoFrame: AgoraVideoFrame, uid _: UInt) -> Bool {
//        memset(videoFrame.uBuffer, 255, Int(videoFrame.uStride * videoFrame.height) / 2)
//        memset(videoFrame.vBuffer, 255, Int(videoFrame.vStride * videoFrame.height) / 2)
        return true
    }
}
