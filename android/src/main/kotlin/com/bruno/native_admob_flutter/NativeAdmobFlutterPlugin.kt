package com.bruno.native_admob_flutter

import android.content.Context
import androidx.annotation.NonNull
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.RequestConfiguration

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** NativeAdmobFlutterPlugin */
class NativeAdmobFlutterPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel

    private lateinit var context: Context

    private lateinit var messenger: BinaryMessenger

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "native_admob_flutter")
        channel.setMethodCallHandler(this)

        context = binding.applicationContext
        messenger = binding.binaryMessenger

        binding
                .platformViewRegistry
                .registerViewFactory("native_admob", NativeViewFactory())
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initialize" -> {
                MobileAds.initialize(context)
                result.success(null)
                println("Initializing mobile ads")
            }
            "initController" -> {
                NativeAdmobControllerManager.createController(call.argument<String>("id")!!, messenger, context)
                result.success(null)
                println("controller created")
            }
            "disposeController" -> {
                NativeAdmobControllerManager.removeController(call.argument<String>("id")!!)
                result.success(null)
                println("controller disposed")
            }
            "setTestDeviceIds" -> {
                call.argument<List<String>>("ids")?.let {
                    val configuration = RequestConfiguration.Builder().setTestDeviceIds(it).build()
                    MobileAds.setRequestConfiguration(configuration)
                    result.success(null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
