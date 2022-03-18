package com.bruno.native_admob_flutter.banner

import android.content.Context
import com.google.android.gms.ads.AdView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class BannerAdController(
        val id: String,
        val channel: MethodChannel,
        val context: Context
) : MethodChannel.MethodCallHandler {

    var adView: AdView? = null

    /// New native ad when loaded
    var loadRequested: ((MethodChannel.Result) -> Unit)? = null

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadAd" -> {
                channel.invokeMethod("loading", null)
                loadRequested?.let { it(result) }
                // Actually, no ads will be loaded here, so return false immediately
                result.success(false)
            }
            else -> result.notImplemented()
        }
    }

}

object BannerAdControllerManager {
    private val controllers: ArrayList<BannerAdController> = arrayListOf()

    fun createController(id: String, binaryMessenger: BinaryMessenger, context: Context) {
        if (getController(id) == null) {
            val methodChannel = MethodChannel(binaryMessenger, id)
            val controller = BannerAdController(id, methodChannel, context)
            controllers.add(controller)
        }
    }

    fun getController(id: String): BannerAdController? {
        return controllers.firstOrNull { it.id == id }
    }

    fun removeController(id: String) {
        val index = controllers.indexOfFirst { it.id == id }
        if (index >= 0) controllers.removeAt(index)
    }
}