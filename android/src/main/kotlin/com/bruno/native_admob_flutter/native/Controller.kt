package com.bruno.native_admob_flutter.native

import android.content.Context
import com.bruno.native_admob_flutter.RequestFactory
import com.bruno.native_admob_flutter.encodeError
import com.google.android.gms.ads.*
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdOptions
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.collections.ArrayList

class NativeAdmobController(
        val id: String,
        val channel: MethodChannel,
        private val context: Context
) : MethodChannel.MethodCallHandler {

    /// New native ad when loaded
    var nativeAdChanged: ((NativeAd?) -> Unit)? = null
    var nativeAdUpdateRequested: ((Map<String, Any?>, NativeAd?) -> Unit)? = null
    var nativeAd: NativeAd? = null

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadAd" -> {
                val unitId = call.argument<String>("unitId") ?: "ca-app-pub-3940256099942544/2247696110"
                val nonPersonalizedAds = call.argument<Boolean>("nonPersonalizedAds")!!
                val keywords = call.argument<List<String>>("keywords")!!
                val options = call.argument<Map<String, Any>>("options")
                loadAd(unitId, options!!, nonPersonalizedAds, keywords, result)
            }
            "updateUI" -> {
                val data = call.argument<Map<String, Any?>>("layout") ?: return
                nativeAdUpdateRequested?.let { it(data, nativeAd) }
                result.success(null)
            }
            "muteAd" -> {
                // yep it's always success :)
                if (nativeAd == null) return result.success(null)
                if (nativeAd!!.isCustomMuteThisAdEnabled)
                    nativeAd?.muteThisAd(nativeAd!!.muteThisAdReasons[call.argument<Int>("reason")!!])
                result.success(null)
            }
            "getHeadline" -> {
                if (nativeAd == null)
                    result.success("loading")
                else
                    result.success(nativeAd!!.getHeadline())
            }
            "getBody" -> {
                if (nativeAd == null)
                    result.success("loading")
                else
                    result.success(nativeAd!!.getBody())
            }
            "getPrice" -> {
                if (nativeAd == null)
                    result.success("loading")
                else
                    result.success(nativeAd!!.getPrice())
            }
            "getStore" -> {
                if (nativeAd == null)
                    result.success("loading")
                else
                    result.success(nativeAd!!.getStore())
            }
            "getCallToAction" -> {
                if (nativeAd == null)
                    result.success("loading")
                else
                    result.success(nativeAd!!.getCallToAction())
            }
            "getAdvertiser" -> {
                if (nativeAd == null)
                    result.success("loading")
                else
                    result.success(nativeAd!!.getAdvertiser())
            }
            "getIconUri" -> {
                if (nativeAd == null)
                    result.success("loading")
                else
                    result.success(nativeAd!!.getIcon().getUri().toString())
            }
            "getImagesUri" -> {
                if (nativeAd == null)
                    result.success(null)
                else {
                    ///List<NativeAd.Image> images = nativeAd!!.getImages()
                    ///val imagesUri: List<String> = emptyList()
                    ///val imagesUri = mutableListOf<String>()
                    var images = nativeAd!!.getImages()
                    if (images == null) return result.success(null)
                    val imagesUri: ArrayList<String> = arrayListOf()
                    for(img in images) {
                        imagesUri.add(img.getUri().toString())
                    }
                    //println(imagesUri)
                    result.success(imagesUri)
                }
                    
            }
            "getFirstImageUri" -> {
                if (nativeAd == null)
                    result.success(null)
                else {
                    var images = nativeAd!!.getImages()
                    if (images == null) return result.success(null)
                    result.success(images[0].getUri().toString())
                }
            }

            else -> result.notImplemented()
        }
    }

    fun undefined() {
        channel.invokeMethod("undefined", null)
    }

    private fun loadAd(unitId: String, options: Map<String, Any>, nonPersonalizedAds: Boolean, keywords: List<String>, result: MethodChannel.Result) {
        channel.invokeMethod("loading", null)
        // ad options
        val adOptions = NativeAdOptions.Builder()
                .setReturnUrlsForImageAssets(options["returnUrlsForImageAssets"] as Boolean)
                .setRequestMultipleImages(options["requestMultipleImages"] as Boolean)
                .setAdChoicesPlacement(options["adChoicesPlacement"] as Int)
                .setMediaAspectRatio(options["mediaAspectRatio"] as Int)
                .setRequestCustomMuteThisAd(options["requestCustomMuteThisAd"] as Boolean)
        val videoOptions = options["videoOptions"] as Map<String, Any>
        val adVideoOptions = VideoOptions.Builder()
                .setStartMuted(videoOptions["startMuted"] as Boolean)
        adOptions.setVideoOptions(adVideoOptions.build())

        // load ad
        AdLoader.Builder(context, unitId)
                .forNativeAd {
                    nativeAd = it
                    nativeAd!!.setMuteThisAdListener {
                        channel.invokeMethod("onAdMuted", null)
                    }
                    if (nativeAd!!.mediaContent.hasVideoContent()) {
                        nativeAd!!.mediaContent.videoController.videoLifecycleCallbacks =
                                object : VideoController.VideoLifecycleCallbacks() {
                                    override fun onVideoStart() {
                                        channel.invokeMethod("onVideoStart", null)
                                    }

                                    override fun onVideoPlay() {
                                        channel.invokeMethod("onVideoPlay", null)
                                    }

                                    override fun onVideoPause() {
                                        channel.invokeMethod("onVideoPause", null)
                                    }

                                    override fun onVideoEnd() {
                                        channel.invokeMethod("onVideoEnd", null)
                                    }

                                    override fun onVideoMute(isMuted: Boolean) {
                                        channel.invokeMethod("onVideoMute", isMuted)
                                    }
                                }
                    }
                }
                .withAdListener(object : AdListener() {

                    override fun onAdLeftApplication() {
                        super.onAdClicked()
                        channel.invokeMethod("onAdLeftApplication", null)
                    }

                    override fun onAdFailedToLoad(error: LoadAdError) {
                        super.onAdFailedToLoad(error)
                        channel.invokeMethod("onAdFailedToLoad", encodeError(error))
                        result.success(false)
                    }

                    override fun onAdLoaded() {
                        super.onAdLoaded()
                        nativeAdChanged?.let { it(nativeAd) }
                        val mediaContent = nativeAd!!.mediaContent
                        channel.invokeMethod("onAdLoaded", hashMapOf(
                                "muteThisAdInfo" to hashMapOf(
                                        "muteThisAdReasons" to nativeAd!!.muteThisAdReasons?.map { it.description } as List<String>,
                                        "isCustomMuteThisAdEnabled" to nativeAd!!.isCustomMuteThisAdEnabled
                                ),
                                "mediaContent" to hashMapOf(
                                        "duration" to mediaContent.duration.toDouble(),
                                        "aspectRatio" to mediaContent.aspectRatio.toDouble(),
                                        "hasVideoContent" to mediaContent.hasVideoContent()
                                )
                        ))
                        result.success(true)
                    }
                })
                .withNativeAdOptions(adOptions.build())
                .build()
                .loadAd(RequestFactory.createAdRequest(nonPersonalizedAds, keywords))
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