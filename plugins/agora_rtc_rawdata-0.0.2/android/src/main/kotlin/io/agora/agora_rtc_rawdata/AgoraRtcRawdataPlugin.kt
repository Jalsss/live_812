package io.agora.agora_rtc_rawdata

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import android.util.Log
import io.agora.rtc.rawdata.base.AudioFrame
import io.agora.rtc.rawdata.base.IAudioFrameObserver
import io.agora.rtc.rawdata.base.IVideoFrameObserver
import io.agora.rtc.rawdata.base.VideoFrame
import io.agora.rtc.rawdata.base.faceunity.FURenderer
import io.agora.rtc.rawdata.base.faceunity.entity.Effect
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.util.*
import java.util.concurrent.CountDownLatch

/** AgoraRtcRawdataPlugin */
class AgoraRtcRawdataPlugin : FlutterPlugin, MethodCallHandler, SensorEventListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel

  private var audioObserver: IAudioFrameObserver? = null
  private var videoObserver: IVideoFrameObserver? = null
  private var mFURender: FURenderer? = null
  private var binding:FlutterPlugin.FlutterPluginBinding ?= null
  private var mSensorManager: SensorManager? = null


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "agora_rtc_rawdata")
    channel.setMethodCallHandler(this)
    binding = flutterPluginBinding
  }


  @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "registerAudioFrameObserver" -> {
        if (audioObserver == null) {
          audioObserver = object : IAudioFrameObserver((call.arguments as Number).toLong()) {
            override fun onRecordAudioFrame(audioFrame: AudioFrame): Boolean {
              return true
            }

            override fun onPlaybackAudioFrame(audioFrame: AudioFrame): Boolean {
              return true
            }

            override fun onMixedAudioFrame(audioFrame: AudioFrame): Boolean {
              return true
            }

            override fun onPlaybackAudioFrameBeforeMixing(uid: Int, audioFrame: AudioFrame): Boolean {
              return true
            }
          }
        }
        audioObserver?.registerAudioFrameObserver()
        result.success(null)
      }
      "unregisterAudioFrameObserver" -> {
        audioObserver?.let {
          it.unregisterAudioFrameObserver()
          audioObserver = null
        }
        result.success(null)
      }
      "registerVideoFrameObserver" -> {
        if (videoObserver == null) {
          FURenderer.initFURenderer(binding!!.applicationContext)
          mFURender = FURenderer.Builder(binding!!.applicationContext)
            .inputTextureType(0)
            .createEGLContext(true)
            .build()

          mSensorManager = binding!!.applicationContext.getSystemService(Context.SENSOR_SERVICE) as SensorManager?
          val sensor = mSensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
          mSensorManager?.registerListener(this, sensor, SensorManager.SENSOR_DELAY_NORMAL)

          mFURender?.onDeviceOrientationChanged(0)

          videoObserver = object : IVideoFrameObserver((call.arguments as Number).toLong()) {
            var isFirst = true

            @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
            override fun onCaptureVideoFrame(videoFrame: VideoFrame): Boolean {
              if (isFirst) {
                mFURender?.onSurfaceCreated()
                isFirst = false
              }

              if (mFURender?.getCurrentThreadID() != java.lang.Thread.currentThread().getId())
                return false

              if (mFURender!= null){
                mFURender?.onDrawFrame(videoFrame.getyBuffer(), videoFrame.getuBuffer(), videoFrame.getvBuffer(), videoFrame.getyStride(), videoFrame.getuStride(), videoFrame.getvStride(), videoFrame.width, videoFrame.height)
              }
              return true
            }

            override fun onRenderVideoFrame(uid: Int, videoFrame: VideoFrame): Boolean {
              // unsigned char value 255
              return true
            }
          }
        }
        videoObserver?.registerVideoFrameObserver()
        result.success(null)
      }
      "unregisterVideoFrameObserver" -> {
        videoObserver?.let {
          val countDown = CountDownLatch(1)
          mFURender?.queueEvent {
            mFURender?.onSurfaceDestroyed()
            countDown.countDown()
          }
          countDown.await()
          mSensorManager?.unregisterListener(this)
          it.unregisterVideoFrameObserver()
          mFURender = null
          videoObserver = null
        }
        result.success(null)
      }

      "enableFaceBeautification" -> {
        mFURender?.onEnableFaceBeautification()
        result.success(null)
      }

      "disableFaceBeautification" -> {
        mFURender?.onDisableFaceBeautification()
        result.success(null)
      }

      "setFaceBeautificationFilter" -> {
        var name = call.argument<String>("filter_name") ?: "origin"
        var level = call.argument<Double?>("filter_level") ?: 0.0
        mFURender?.onFilterSelected(name, level)
        result.success(null)
      }

      "setFaceBeautificationSkinWhitening" -> {
        var level = call.argument<Double?>("color_level") ?: 0.5
        mFURender?.onSkinWhiteningSelected(level)
        result.success(null)
      }

      "setFaceBeautificationRuddy" -> {
        var level = call.argument<Double?>("red_level") ?: 0.5
        mFURender?.onRuddySelected(level)
        result.success(null)
      }

      "setFaceBeautificationBlur" -> {
        var bl = call.argument<Double?>("blur_level") ?: 0.0
        var sd = call.argument<Int?>("skin_detect") ?: 0
        var nbs = call.argument<Double?>("nonskin_blur_scale") ?: 0.45
        var hb = call.argument<Int?>("heavy_blur") ?: 0
        mFURender?.onBlurSelected(bl, sd, nbs, hb)
        result.success(null)
      }

      "setFaceBeautificationEyeBrighten" -> {
        var bright = call.argument<Double?>("eye_bright") ?: 0.0
        mFURender?.onEyeBrightenSelected(bright);
        result.success(null)
      }

      "setFaceBeautificationToothWhiten" -> {
        var whiten = call.argument<Double?>("tooth_whiten") ?: 0.0
        mFURender?.onToothWhitenSelected(whiten)
        result.success(null)
      }

      "setFaceBeautificationFaceOutline" -> {
        var fs = call.argument<Int?>("face_shape") ?: 3
        var fsl = call.argument<Double?>("face_shape_level") ?: 0.0
        var ee = call.argument<Double?>("eye_enlarging") ?: 0.0
        var ct = call.argument<Double?>("cheek_thinning") ?: 0.0
        var iF = call.argument<Double?>("intensity_forehead") ?: 0.5
        var iC = call.argument<Double?>("intensity_chin") ?: 0.5
        var iN = call.argument<Double?>("intensity_nose") ?: 0.0
        var iM = call.argument<Double?>("intensity_mouth") ?: 0.5
        mFURender?.onFaceOutlineSelected(fs, fsl, ee, ct, iF, iC, iN, iM)
        result.success(null)
      }

      "removeMask" -> {
        mFURender?.queueEvent(Runnable {
          mFURender.run {
            //(String bundleName, int resId, String path, int maxFace, int effectType, int description)
            val  effect = Effect("",1,"",2,Effect.EFFECT_TYPE_NORMAL,1)
            mFURender?.onEffectSelected(effect )

          }
        })

        result.success(null)
      }

      "lanhudie" -> {
        mFURender?.queueEvent(Runnable {
          mFURender.run {
            //(String bundleName, int resId, String path, int maxFace, int effectType, int description)
            val  effect = Effect("tiger",1,"effect/ar/lanhudie.bundle",2,Effect.EFFECT_TYPE_NORMAL,1)
            mFURender?.onEffectSelected(effect )

          }
        })

        result.success(null)
      }

      "etye_zh_fu" -> {
        mFURender?.queueEvent(Runnable {
          mFURender.run {
            //(String bundleName, int resId, String path, int maxFace, int effectType, int description)
            val  effect = Effect("tiger",1,"effect/ar/etye_zh_fu.bundle",2,Effect.EFFECT_TYPE_NORMAL,1)
            mFURender?.onEffectSelected(effect )

          }
        })

        result.success(null)
      }

      "redribbt" -> {
        mFURender?.queueEvent(Runnable {
          mFURender.run {
            //(String bundleName, int resId, String path, int maxFace, int effectType, int description)
            val  effect = Effect("tiger",1,"effect/normal/redribbt.bundle",2,Effect.EFFECT_TYPE_NORMAL,1)
            mFURender?.onEffectSelected(effect )

          }
        })

        result.success(null)
      }

      "xlong_zh_fu" -> {
        mFURender?.queueEvent(Runnable {
          mFURender.run {
            //(String bundleName, int resId, String path, int maxFace, int effectType, int description)
            val  effect = Effect("tiger",1,"effect/normal/xlong_zh_fu.bundle",2,Effect.EFFECT_TYPE_NORMAL,1)
            mFURender?.onEffectSelected(effect )

          }
        })

        result.success(null)
      }

      "CatSparks" -> {
        mFURender?.queueEvent(Runnable {
          mFURender.run {
            //(String bundleName, int resId, String path, int maxFace, int effectType, int description)
            val  effect = Effect("tiger",1,"effect/normal/cat_sparks.bundle",2,Effect.EFFECT_TYPE_NORMAL,1)
            mFURender?.onEffectSelected(effect )

          }
        })

        result.success(null)
      }

      "baozi" -> {
        mFURender?.queueEvent(Runnable {
          mFURender.run {
            //(String bundleName, int resId, String path, int maxFace, int effectType, int description)
            val  effect = Effect("tiger",1,"effect/ar/baozi.bundle",2,Effect.EFFECT_TYPE_NORMAL,1)
            mFURender?.onEffectSelected(effect )

          }
        })

        result.success(null)
      }

      "xiongmao" -> {
        mFURender?.queueEvent(Runnable {
          mFURender.run {
            //(String bundleName, int resId, String path, int maxFace, int effectType, int description)
            val  effect = Effect("tiger",1,"effect/ar/xiongmao.bundle",2,Effect.EFFECT_TYPE_NORMAL,1)
            mFURender?.onEffectSelected(effect )

          }
        })


        result.success(null)
      }

      "tiger" -> {

        mFURender?.queueEvent(Runnable {
          mFURender.run {
            //(String bundleName, int resId, String path, int maxFace, int effectType, int description)
            val  effect = Effect("tiger",1,"effect/ar/tiger.bundle",2,Effect.EFFECT_TYPE_NORMAL,1)
            mFURender?.onEffectSelected(effect )

          }
        })
        result.success(null)
      }

      "tiger_bai" -> {
        mFURender?.queueEvent(Runnable {
          mFURender.run {
            //(String bundleName, int resId, String path, int maxFace, int effectType, int description)
            val  effect = Effect("tiger",1,"effect/ar/tiger_bai.bundle",2,Effect.EFFECT_TYPE_NORMAL,1)
            mFURender?.onEffectSelected(effect )

          }
        })

        result.success(null)
      }

      "bluebird" -> {
        mFURender?.queueEvent(Runnable {
          mFURender.run {
            //(String bundleName, int resId, String path, int maxFace, int effectType, int description)
            val  effect = Effect("tiger",1,"effect/ar/bluebird.bundle",2,Effect.EFFECT_TYPE_NORMAL,1)
            mFURender?.onEffectSelected(effect )

          }
        })

        result.success(null)
      }


      "fenhudie" -> {
        mFURender?.queueEvent(Runnable {
          mFURender.run {
            //(String bundleName, int resId, String path, int maxFace, int effectType, int description)
            val  effect = Effect("tiger",1,"effect/ar/fenhudie.bundle",2,Effect.EFFECT_TYPE_NORMAL,1)
            mFURender?.onEffectSelected(effect )

          }
        })

        result.success(null)
      }

      "tiger_huang" -> {
        mFURender?.queueEvent(Runnable {
          mFURender.run {
            //(String bundleName, int resId, String path, int maxFace, int effectType, int description)
            val  effect = Effect("tiger",1,"effect/ar/tiger_huang.bundle",2,Effect.EFFECT_TYPE_NORMAL,1)
            mFURender?.onEffectSelected(effect )

          }
        })

        result.success(null)
      }

      else -> result.notImplemented()
    }

  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  companion object {
    // Used to load the 'native-lib' library on application startup.
    init {
      System.loadLibrary("cpp")
    }
  }
  // 屏幕旋转时调用的方法
  // 画面が回転したときに呼び出されるメソッド
  override fun onSensorChanged(event: SensorEvent?) {
    val x = event!!.values[0]
    val y = event.values[1]
    if (Math.abs(x) > 3 || Math.abs(y) > 3) {
      if (Math.abs(x) > Math.abs(y)) {
        mFURender?.onDeviceOrientationChanged(if (x > 0) 0 else 180)
      } else {
        mFURender?.onDeviceOrientationChanged(if (y > 0) 90 else 270)
      }
    }
  }

  override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {

  }

}
