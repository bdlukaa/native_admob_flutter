package com.nover.flutternativeadmob

import android.content.Context
import android.content.res.Resources
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.view.View
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.RequestConfiguration
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class FlutterNativeAdmobPlugin(
    private val context: Context,
    private val messenger: BinaryMessenger
) : MethodCallHandler {

  enum class CallMethod {
    initController, disposeController, setTestDeviceIds, initialize
  }

    private val viewType = "native_admob"

//    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val messenger = registrar.messenger()
      val channel = MethodChannel(messenger, "flutter_native_admob")

      val instance = FlutterNativeAdmobPlugin(registrar.context(), messenger)
      channel.setMethodCallHandler(instance)

      // create platform view
      registrar
          .platformViewRegistry()
          .registerViewFactory(viewType, ViewFactory())

//      MobileAds.initialize(context) {
//        println(it)
//      }
    }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (CallMethod.valueOf(call.method)) {
      CallMethod.initialize -> {
        (call.argument<String>("admob_app_id"))?.let {
          MobileAds.initialize(context, it)
          result.success(null)
        }
      }
      CallMethod.initController -> {
        (call.argument<String>("controllerID"))?.let {
          NativeAdmobControllerManager.createController(it, messenger, context)
        }
      }

      CallMethod.disposeController -> {
        (call.argument<String>("controllerID"))?.let {
          NativeAdmobControllerManager.removeController(it)
        }
      }

      CallMethod.setTestDeviceIds -> {
        (call.argument<List<String>>("testDeviceIds"))?.let {
          val configuration = RequestConfiguration.Builder().setTestDeviceIds(it).build()
          MobileAds.setRequestConfiguration(configuration)
        }
      }
    }
  }
}

class ViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

  override fun create(context: Context, id: Int, params: Any?): PlatformView {
    return NativePlatformView(context, id, params)
  }
}

class NativePlatformView(
    context: Context,
    id: Int,
    params: Any?
) : PlatformView {

  private var controller: NativeAdmobController? = null
  private val view: NativeAdView

  init {
    val map = params as Map<*, *>

    println(map)

    view = NativeAdView(context, map)

    (map["controllerID"] as? String)?.let { id ->
      val controller = NativeAdmobControllerManager.getController(id)
      controller?.nativeAdChanged = { view.setNativeAd(it) }
      this.controller = controller
    }

    controller?.nativeAd?.let {
      view.setNativeAd(it)
    }
  }

  override fun getView(): View = view

  override fun dispose() {}
}
//
//fun Int.toRoundedColor(radius: Float): Drawable {
//  val drawable = GradientDrawable()
//  drawable.shape = GradientDrawable.RECTANGLE
//  drawable.cornerRadius = radius * Resources.getSystem().displayMetrics.density
//  drawable.setColor(this)
//  return drawable
//}
//
//fun Int.dp(): Int {
//  val density = Resources.getSystem().displayMetrics.density
//  return (this * density).toInt()
//}
