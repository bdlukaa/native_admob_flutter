package com.bruno.native_admob_flutter

import android.app.Activity
import android.content.Context
import android.content.res.Resources
import android.os.Build
import androidx.annotation.NonNull
import com.bruno.native_admob_flutter.banner.*
import com.bruno.native_admob_flutter.interstitial.InterstitialAdControllerManager
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.RequestConfiguration

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import com.bruno.native_admob_flutter.native.*
import com.bruno.native_admob_flutter.rewarded.RewardedAdControllerManager
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

class NativeAdmobFlutterPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {
    private lateinit var channel: MethodChannel

    private lateinit var activity: Activity

    private lateinit var messenger: BinaryMessenger

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "native_admob_flutter")
        channel.setMethodCallHandler(this)

        messenger = binding.binaryMessenger

        binding.platformViewRegistry.registerViewFactory("native_admob", NativeViewFactory())
        binding.platformViewRegistry.registerViewFactory("banner_admob", BannerAdViewFactory())
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initialize" -> {
                MobileAds.initialize(activity) { result.success(Build.VERSION.SDK_INT) }
            }
            // Native Ads Controller
            "initNativeAdController" -> {
                NativeAdmobControllerManager.createController(call.argument<String>("id")!!, messenger, activity)
                result.success(null)
            }
            "disposeNativeAdController" -> {
                NativeAdmobControllerManager.removeController(call.argument<String>("id")!!)
                result.success(null)
            }
            // Banner Ads Controller
            "initBannerAdController" -> {
                BannerAdControllerManager.createController(
                        call.argument<String>("id")!!,
                        messenger,
                        activity)
                result.success(null)
            }
            "disposeBannerAdController" -> {
                BannerAdControllerManager.removeController(call.argument<String>("id")!!)
                result.success(null)
            }
            // Interstitial
            "initInterstitialAd" -> {
                InterstitialAdControllerManager.createController(
                        call.argument<String>("id")!!,
                        call.argument<String>("unitId")!!,
                        messenger,
                        activity)
                result.success(null)
            }
            "disposeInterstitialAd" -> {
                InterstitialAdControllerManager.removeController(call.argument<String>("id")!!)
                result.success(null)
            }
            // Rewarded
            "initRewardedAd" -> {
                val controller = RewardedAdControllerManager.createController(
                        call.argument<String>("id")!!,
                        call.argument<String>("unitId")!!,
                        messenger,
                        activity)
                val reward = controller.rewardedAd.rewardItem
                result.success(hashMapOf(
                        "amount" to reward?.amount,
                        "type" to reward?.type
                ))
            }
            "disposeRewardedAd" -> {
                RewardedAdControllerManager.removeController(call.argument<String>("id")!!)
                result.success(null)
            }
            // General Controller
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

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }
}
