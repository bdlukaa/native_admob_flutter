package com.bruno.native_admob_flutter.rewarded

import android.app.Activity
import com.bruno.native_admob_flutter.encodeError
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.rewarded.RewardItem
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdCallback
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class RewardedAdController(
        val id: String,
        unitId: String,
        val channel: MethodChannel,
        private val activity: Activity
) : MethodChannel.MethodCallHandler {

    val rewardedAd: RewardedAd
    private lateinit var callback: RewardedAdLoadCallback

    init {
        channel.setMethodCallHandler(this)
        rewardedAd = RewardedAd(activity, unitId)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadAd" -> {
                channel.invokeMethod("loading", null)
                callback = object : RewardedAdLoadCallback() {
                    override fun onRewardedAdLoaded() {
                        channel.invokeMethod("onAdLoaded", null)
                        result.success(true)
                    }

                    override fun onRewardedAdFailedToLoad(error: LoadAdError) {
                        channel.invokeMethod("onAdFailedToLoad", encodeError(error))
                        result.success(false)
                    }
                }
                rewardedAd.loadAd(AdRequest.Builder().build(), callback)
            }
            "show" -> {
                val adCallback: RewardedAdCallback = object : RewardedAdCallback() {
                    override fun onRewardedAdOpened() {
                        channel.invokeMethod("onRewardedAdOpened", null)
                    }

                    override fun onRewardedAdClosed() {
                        channel.invokeMethod("onRewardedAdClosed", null)
                        result.success(true)
                    }

                    override fun onUserEarnedReward(reward: RewardItem) {
                        channel.invokeMethod("onUserEarnedReward", hashMapOf<String, Any>(
                                "amount" to reward.amount,
                                "type" to reward.type
                        ))
                    }

                    override fun onRewardedAdFailedToShow(error: AdError) {
                        channel.invokeMethod("onRewardedAdFailedToShow", encodeError(error))
                        result.success(false)
                    }
                }
                rewardedAd.show(activity, adCallback)
            }
            else -> result.notImplemented()
        }
    }

}

object RewardedAdControllerManager {
    private val controllers: ArrayList<RewardedAdController> = arrayListOf()

    fun createController(id: String, unitId: String, binaryMessenger: BinaryMessenger, activity: Activity): RewardedAdController {
        if (getController(id) == null) {
            val methodChannel = MethodChannel(binaryMessenger, id)
            val controller = RewardedAdController(id, unitId, methodChannel, activity)
            controllers.add(controller)
            return controller
        }
        return getController(id)!!
    }

    private fun getController(id: String): RewardedAdController? {
        return controllers.firstOrNull { it.id == id }
    }

    fun removeController(id: String) {
        val index = controllers.indexOfFirst { it.id == id }
        if (index >= 0) controllers.removeAt(index)
    }
}