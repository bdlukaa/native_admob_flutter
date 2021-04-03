package com.bruno.native_admob_flutter.interstitial

import android.app.Activity
import com.bruno.native_admob_flutter.RequestFactory
import com.bruno.native_admob_flutter.encodeError
import com.google.android.gms.ads.*
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class InterstitialAdController(
        val id: String,
        val channel: MethodChannel,
        private val context: Activity
) : MethodChannel.MethodCallHandler {

    private var mInterstitialAd: InterstitialAd? = null

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadAd" -> {
                channel.invokeMethod("loading", null)
                val unitId = call.argument<String>("unitId")!!
                val nonPersonalizedAds = call.argument<Boolean>("nonPersonalizedAds")!!
                InterstitialAd.load(context, unitId, RequestFactory.createAdRequest(nonPersonalizedAds), object : InterstitialAdLoadCallback() {
                    override fun onAdFailedToLoad(error: LoadAdError) {
                        mInterstitialAd = null
                        channel.invokeMethod("onAdFailedToLoad", encodeError(error))
                        result.success(false)
                    }

                    override fun onAdLoaded(interstitialAd: InterstitialAd) {
                        mInterstitialAd = interstitialAd
                        channel.invokeMethod("onAdLoaded", null)
                        result.success(true)
                    }
                })
            }
            "show" -> {
                if (mInterstitialAd == null) return result.success(false)
                mInterstitialAd!!.show(context)
                mInterstitialAd!!.fullScreenContentCallback = object : FullScreenContentCallback() {
                    override fun onAdDismissedFullScreenContent() {
                        channel.invokeMethod("onAdDismissedFullScreenContent", null)
                        result.success(true)
                    }

                    override fun onAdFailedToShowFullScreenContent(error: AdError?) {
                        channel.invokeMethod("onAdFailedToShowFullScreenContent", encodeError(error))
                        result.success(false)
                    }

                    override fun onAdShowedFullScreenContent() {
                        channel.invokeMethod("onAdShowedFullScreenContent", null)
                        mInterstitialAd = null
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

}

object InterstitialAdControllerManager {
    private val controllers: ArrayList<InterstitialAdController> = arrayListOf()

    fun createController(id: String, binaryMessenger: BinaryMessenger, context: Activity) {
        if (getController(id) == null) {
            val methodChannel = MethodChannel(binaryMessenger, id)
            val controller = InterstitialAdController(id, methodChannel, context)
            controllers.add(controller)
        }
    }

    private fun getController(id: String): InterstitialAdController? {
        return controllers.firstOrNull { it.id == id }
    }

    fun removeController(id: String) {
        val index = controllers.indexOfFirst { it.id == id }
        if (index >= 0) controllers.removeAt(index)
    }
}