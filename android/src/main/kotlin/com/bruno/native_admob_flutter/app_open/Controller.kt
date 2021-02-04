package com.bruno.native_admob_flutter.app_open

import android.app.Activity
import com.bruno.native_admob_flutter.encodeError
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.appopen.AppOpenAd
import com.google.android.gms.ads.appopen.AppOpenAd.AppOpenAdLoadCallback
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AppOpenAdController(
        val id: String,
        private val channel: MethodChannel,
        private val context: Activity
) : MethodChannel.MethodCallHandler {

    private var appOpenAd: AppOpenAd? = null

    private fun fetchAd(unitId: String, orientation: Int, loadCallback: AppOpenAdLoadCallback) {
        if (isAdAvailable()) return
        AdRequest.Builder().build()
        AppOpenAd.load(context, unitId, AdRequest.Builder().build(), orientation, loadCallback)
    }


    private fun isAdAvailable(): Boolean {
        return appOpenAd != null
    }

    private var isShowingAd = false

    private fun showAdIfAvailable(fullScreenContentCallback: FullScreenContentCallback) {
        if (!isShowingAd && isAdAvailable()) {
            appOpenAd!!.show(context, fullScreenContentCallback)
        }
    }

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadAd" -> {
                channel.invokeMethod("loading", null)
                val unitId: String = call.argument<String>("unitId")!!
                val orientation: Int = call.argument<Int>("orientation")!!
                val loadCallback = object : AppOpenAdLoadCallback() {
                    override fun onAppOpenAdLoaded(ad: AppOpenAd) {
                        appOpenAd = ad
                        channel.invokeMethod("onAppOpenAdLoaded", null)
                        result.success(null)
                    }

                    override fun onAppOpenAdFailedToLoad(loadAdError: LoadAdError) {
                        channel.invokeMethod("onAppOpenAdFailedToLoad", encodeError(loadAdError))
                        result.error(loadAdError.code.toString(), loadAdError.message, null)
                    }
                }
                fetchAd(unitId, orientation, loadCallback)
            }
            "showAd" -> {
                val fullScreenContentCallback: FullScreenContentCallback = object : FullScreenContentCallback() {
                    override fun onAdDismissedFullScreenContent() {
                        // Set the reference to null so isAdAvailable() returns false.
                        appOpenAd = null
                        isShowingAd = false
                        channel.invokeMethod("onAdDismissedFullScreenContent", null)
                    }

                    override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                        channel.invokeMethod("onAdFailedToShowFullScreenContent", encodeError(adError))
                        result.error(adError.code.toString(), adError.message, null)
                    }

                    override fun onAdShowedFullScreenContent() {
                        isShowingAd = true
                        channel.invokeMethod("onAdShowedFullScreenContent", null)
                        result.success(null)
                    }
                }
                showAdIfAvailable(fullScreenContentCallback)
            }
        }
    }
}

object AppOpenAdControllerManager {
    private val controllers: ArrayList<AppOpenAdController> = arrayListOf()

    fun createController(id: String, binaryMessenger: BinaryMessenger, context: Activity) {
        if (getController(id) == null) {
            val methodChannel = MethodChannel(binaryMessenger, id)
            val controller = AppOpenAdController(id, methodChannel, context)
            controllers.add(controller)
        }
    }

    private fun getController(id: String): AppOpenAdController? {
        return controllers.firstOrNull { it.id == id }
    }

    fun removeController(id: String) {
        val index = controllers.indexOfFirst { it.id == id }
        if (index >= 0) controllers.removeAt(index)
    }
}