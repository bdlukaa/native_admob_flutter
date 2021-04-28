package com.bruno.native_admob_flutter

import android.os.Bundle
import com.google.ads.mediation.admob.AdMobAdapter
import com.google.android.gms.ads.AdRequest

class RequestFactory {

    companion object {
        fun createAdRequest(nonPersonalizedAds: Boolean, keywords: List<String>) : AdRequest {
            val builder = AdRequest.Builder()
            if (nonPersonalizedAds) {
                val extras = Bundle()
                extras.putString("npa", "1")
                builder.addNetworkExtrasBundle(AdMobAdapter::class.java, extras)
            }
            keywords.forEach() {
                builder.addKeyword(it)
            }
            return builder.build()
        }
    }

}