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
                MobileAds.initialize(context) { result.success(null) }
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
            // isTestDevice method is not found. Idk why
//            "isTestDevice" -> result.success(AdRequest.isTestDevice(context))
            "setTestDeviceIds" -> {
                val configuration = MobileAds
                        .getRequestConfiguration()
                        .toBuilder()
                        .setTestDeviceIds(call.argument<List<String>>("ids"))
                        .build()
                MobileAds.setRequestConfiguration(configuration)
                result.success(null)
            }
            "setChildDirected" -> {
                val child: Int = when (call.argument<Boolean>("directed")) {
                    true -> RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_TRUE
                    false -> RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_FALSE
                    null -> RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_UNSPECIFIED
                }
                val configuration = MobileAds
                        .getRequestConfiguration()
                        .toBuilder()
                        .setTagForChildDirectedTreatment(child)
                        .build()
                MobileAds.setRequestConfiguration(configuration)
                result.success(null)
            }
            "setTagForUnderAgeOfConsent" -> {
                val age: Int = when (call.argument<Boolean>("under")) {
                    true -> RequestConfiguration.TAG_FOR_UNDER_AGE_OF_CONSENT_TRUE
                    false -> RequestConfiguration.TAG_FOR_UNDER_AGE_OF_CONSENT_FALSE
                    null -> RequestConfiguration.TAG_FOR_UNDER_AGE_OF_CONSENT_UNSPECIFIED
                }
                val configuration = MobileAds
                        .getRequestConfiguration()
                        .toBuilder()
                        .setTagForUnderAgeOfConsent(age)
                        .build()
                MobileAds.setRequestConfiguration(configuration)
                result.success(null)
            }
            "setMaxAdContentRating" -> {
                val age: String = when (call.argument<Int>("maxRating")) {
                    0 -> RequestConfiguration.MAX_AD_CONTENT_RATING_G
                    1 -> RequestConfiguration.MAX_AD_CONTENT_RATING_PG
                    2 -> RequestConfiguration.MAX_AD_CONTENT_RATING_T
                    3 -> RequestConfiguration.MAX_AD_CONTENT_RATING_MA
                    else -> RequestConfiguration.MAX_AD_CONTENT_RATING_G
                }
                val configuration = MobileAds
                        .getRequestConfiguration()
                        .toBuilder()
                        .setMaxAdContentRating(age)
                        .build()
                MobileAds.setRequestConfiguration(configuration)
                result.success(null)
            }
            "setAppVolume" -> {
                val volume: Float = call.argument<Double>("volume")!!.toFloat()
                MobileAds.setAppVolume(volume)
                result.success(null)
            }
            "setAppMuted" -> {
                val muted: Boolean = call.argument<Boolean>("muted")!!
                MobileAds.setAppMuted(muted)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
