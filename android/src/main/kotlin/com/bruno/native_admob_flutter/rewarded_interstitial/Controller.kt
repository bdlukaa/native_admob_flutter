package com.bruno.native_admob_flutter.rewarded_interstitial

import android.app.Activity
import com.bruno.native_admob_flutter.RequestFactory
import com.bruno.native_admob_flutter.encodeError
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.rewardedinterstitial.RewardedInterstitialAd
import com.google.android.gms.ads.rewardedinterstitial.RewardedInterstitialAdLoadCallback
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class RewardedInterstitialController(
        val id: String,
        private val channel: MethodChannel,
        private val context: Activity
) : MethodChannel.MethodCallHandler {

    private var rewardedInterstitialAd: RewardedInterstitialAd? = null

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        print(call.method)
        when(call.method) {
            "loadAd" -> {
                channel.invokeMethod("loading", null)
                val unitId: String = call.argument<String>("unitId")!!
                val nonPersonalizedAds = call.argument<Boolean>("nonPersonalizedAds")!!
                RewardedInterstitialAd.load(context, unitId, RequestFactory.createAdRequest(nonPersonalizedAds), object : RewardedInterstitialAdLoadCallback() {
                    override fun onAdLoaded(ad: RewardedInterstitialAd) {
                        rewardedInterstitialAd = ad
                        channel.invokeMethod("onAdLoaded", null)
                        result.success(true)
                    }

                    override fun onAdFailedToLoad(loadAdError: LoadAdError) {
                        rewardedInterstitialAd = null
                        channel.invokeMethod("onAdFailedToLoad", encodeError(loadAdError))
                        result.success(false)
                    }
                })
            }
            "showAd" -> {
                if (rewardedInterstitialAd == null) return result.success(false)
                rewardedInterstitialAd!!.fullScreenContentCallback = object : FullScreenContentCallback() {
                    override fun onAdDismissedFullScreenContent() {
                        channel.invokeMethod("onAdDismissedFullScreenContent", null)
                        result.success(true)
                    }

                    override fun onAdFailedToShowFullScreenContent(error: AdError?) {
                        channel.invokeMethod("onAdFailedToShowFullScreenContent", encodeError(error))
                        result.success(false)
                    }

                    override fun onAdShowedFullScreenContent() {
                        rewardedInterstitialAd = null
                        channel.invokeMethod("onAdShowedFullScreenContent", null)
                    }
                }
                rewardedInterstitialAd!!.show(context) { reward ->
                    channel.invokeMethod("onUserEarnedReward", hashMapOf<String, Any>(
                            "amount" to reward.amount,
                            "type" to reward.type
                    ))
                }
            }
            else -> result.notImplemented();
        }
    }
}

object RewardedInterstitialAdControllerManager {
    private val controllers: ArrayList<RewardedInterstitialController> = arrayListOf()

    fun createController(id: String, binaryMessenger: BinaryMessenger, activity: Activity): RewardedInterstitialController {
        if (getController(id) == null) {
            val methodChannel = MethodChannel(binaryMessenger, id)
            val controller = RewardedInterstitialController(id, methodChannel, activity)
            controllers.add(controller)
            return controller
        }
        return getController(id)!!
    }

    private fun getController(id: String): RewardedInterstitialController? {
        return controllers.firstOrNull { it.id == id }
    }

    fun removeController(id: String) {
        val index = controllers.indexOfFirst { it.id == id }
        if (index >= 0) controllers.removeAt(index)
    }
}