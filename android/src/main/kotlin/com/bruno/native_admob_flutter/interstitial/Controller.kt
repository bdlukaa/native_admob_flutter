package com.bruno.native_admob_flutter.interstitial

import android.content.Context
import com.bruno.native_admob_flutter.encodeError
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.InterstitialAd
import com.google.android.gms.ads.LoadAdError
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class InterstitialAdController(
        val id: String,
        unitId: String,
        val channel: MethodChannel,
        context: Context
) : MethodChannel.MethodCallHandler {

    private var mInterstitialAd: InterstitialAd

    init {
        channel.setMethodCallHandler(this)
        mInterstitialAd = InterstitialAd(context)
        mInterstitialAd.adUnitId = unitId
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadAd" -> {
                channel.invokeMethod("loading", null)
                mInterstitialAd.loadAd(AdRequest.Builder().build())
                mInterstitialAd.adListener = object : AdListener() {
                    override fun onAdLoaded() {
                        channel.invokeMethod("onAdLoaded", null)
                        result.success(true)
                    }

                    override fun onAdFailedToLoad(error: LoadAdError) {
                        channel.invokeMethod("onAdFailedToLoad", encodeError(error))
                        result.success(false)
                    }

                    override fun onAdOpened() {
                        channel.invokeMethod("onAdOpened", null)
                    }

                    override fun onAdClicked() {
                        channel.invokeMethod("onAdClicked", null)
                    }

                    override fun onAdLeftApplication() {
                        channel.invokeMethod("onAdLeftApplication", null)
                    }

                    override fun onAdClosed() {
                        channel.invokeMethod("onAdClosed", null)
                    }
                }
            }
            "show" -> {
                mInterstitialAd.show()
                mInterstitialAd.adListener = object : AdListener() {
                    override fun onAdLoaded() {
                        channel.invokeMethod("onAdLoaded", null)
                    }

                    override fun onAdFailedToLoad(error: LoadAdError) {
                        channel.invokeMethod("onAdFailedToLoad", encodeError(error))
                    }

                    override fun onAdOpened() {
                        channel.invokeMethod("onAdOpened", null)
                    }

                    override fun onAdClicked() {
                        channel.invokeMethod("onAdClicked", null)
                    }

                    override fun onAdLeftApplication() {
                        channel.invokeMethod("onAdLeftApplication", null)
                    }

                    override fun onAdClosed() {
                        channel.invokeMethod("onAdClosed", null)
                        result.success(true)
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

}

object InterstitialAdControllerManager {
    private val controllers: ArrayList<InterstitialAdController> = arrayListOf()

    fun createController(id: String, unitId: String, binaryMessenger: BinaryMessenger, context: Context) {
        if (getController(id) == null) {
            val methodChannel = MethodChannel(binaryMessenger, id)
            val controller = InterstitialAdController(id, unitId, methodChannel, context)
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