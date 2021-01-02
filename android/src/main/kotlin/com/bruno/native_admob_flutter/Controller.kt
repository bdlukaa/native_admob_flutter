package com.bruno.native_admob_flutter

import android.content.Context
import com.google.android.gms.ads.*
import com.google.android.gms.ads.formats.UnifiedNativeAd
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*
import kotlin.collections.ArrayList

class NativeAdmobController(
        val id: String,
        val channel: MethodChannel,
        private val context: Context
) : MethodChannel.MethodCallHandler {

    /// New native ad when loaded
    var nativeAdChanged: ((UnifiedNativeAd?) -> Unit)? = null
    var nativeAdUpdateRequested: ((Map<String, Any?>, UnifiedNativeAd?) -> Unit)? = null
    var nativeAd: UnifiedNativeAd? = null

    private var nonPersonalizedAds = false

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadAd" -> {
                val unitId = call.argument<String>("unitId")
                if (unitId == null) {
                    result.error("no_unit_id", "An unit id is necessary", null)
                    return
                }
                loadAd(unitId)
                result.success(null)
            }
            "updateUI" -> {
                val data = call.argument<Map<String, Any?>>("layout") ?: return
                nativeAdUpdateRequested?.let { it(data, nativeAd) }
                result.success(null)
            }
            "setNonPersonalizedAds" -> {
                call.argument<Boolean>("nonPersonalizedAds")?.let {
                    nonPersonalizedAds = it
                }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    fun undefined() {
        channel?.invokeMethod("undefined", null)
    }

    private fun loadAd(unitId: String) {
        channel.invokeMethod("loading", null)
        val builder = AdLoader.Builder(context, unitId)
//        if(nonPersonalizedAds){
//            val extras = Bundle().apply {
//                putString("npa", "1")
//            }
//            builder.addNetworkExtrasBundle(AdMobAdapter::class.java, extras)
//        }
        builder.forUnifiedNativeAd { this.nativeAd = it }.withAdListener(object : AdListener() {
            override fun onAdImpression() {
                super.onAdImpression()
                channel.invokeMethod("onAdImpression", null)
            }

            override fun onAdClicked() {
                super.onAdClicked()
                channel.invokeMethod("onAdClicked", null)
            }

            override fun onAdFailedToLoad(error: LoadAdError) {
                super.onAdFailedToLoad(error)
                channel.invokeMethod("onAdFailedToLoad", hashMapOf("errorCode" to error.code))
            }

            override fun onAdLoaded() {
                super.onAdLoaded()
                nativeAdChanged?.let { it(nativeAd) }
                channel.invokeMethod("onAdLoaded", null)
            }
        }).build().loadAd(AdRequest.Builder().build())
    }

}

object NativeAdmobControllerManager {
    private val controllers: ArrayList<NativeAdmobController> = arrayListOf()

    fun createController(id: String, binaryMessenger: BinaryMessenger, context: Context) {
        if (getController(id) == null) {
            val methodChannel = MethodChannel(binaryMessenger, id)
            val controller = NativeAdmobController(id, methodChannel, context)
            controllers.add(controller)
        }
    }

    fun getController(id: String): NativeAdmobController? {
        return controllers.firstOrNull { it.id == id }
    }

    fun removeController(id: String) {
        val index = controllers.indexOfFirst { it.id == id }
        if (index >= 0) controllers.removeAt(index)
    }
}