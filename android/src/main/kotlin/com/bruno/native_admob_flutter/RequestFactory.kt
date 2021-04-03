package com.bruno.native_admob_flutter

import android.os.Bundle
import com.google.ads.mediation.admob.AdMobAdapter
import com.google.android.gms.ads.AdRequest

class RequestFactory {

    companion object {
        fun createAdRequest(nonPersonalizedAds: Boolean) : AdRequest {
            val builder = AdRequest.Builder()
            if (nonPersonalizedAds) {
                val extras = Bundle()
                extras.putString("npa", "1")
                builder.addNetworkExtrasBundle(AdMobAdapter::class.java, extras)
            }
            return builder.build()
        }
    }

}