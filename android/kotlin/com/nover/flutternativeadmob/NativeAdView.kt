package com.nover.flutternativeadmob

import android.content.Context
import android.graphics.Color
import android.media.Rating
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.*
import com.google.android.gms.ads.formats.MediaView
import com.google.android.gms.ads.formats.UnifiedNativeAd
import com.google.android.gms.ads.formats.UnifiedNativeAdView

class NativeAdView @JvmOverloads constructor(
        context: Context,
        data: Map<*, *>,
        attrs: AttributeSet? = null,
        defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

    private val adView: UnifiedNativeAdView

    private var ratingBar: RatingBar? = null

    private var adMedia: MediaView? = null
    private var adIcon: ImageView? = null

    private var adHeadline: TextView? = null
    private var adAdvertiser: TextView? = null
    private var adBody: TextView? = null
    private var adPrice: TextView? = null
    private var adStore: TextView? = null
    private var adAttribution: TextView? = null
    private var callToAction: Button? = null

    private fun build(data: Map<*, *>): View {
        return buildView(data)
    }

    private fun buildView(data: Map<*, *>): View {
        val viewType: String = data["viewType"] as String
        var view = View(context)
        when (viewType) {
            "linear_layout" -> {
                view = LinearLayout(context)
                view.orientation = if (data["orientation"] as String == "vertical")
                    VERTICAL
                else HORIZONTAL

                if (data["children"] != null)
                    for (child in data["children"] as List<*>)
                        view.addView(buildView(child as Map<*, *>))
            }
            "text_view" -> {
                view = TextView(context)
                (data["textSize"] as? Double?)?.toFloat()?.also { (view as TextView).textSize = it }
                (data["textColor"] as? String)?.let { (view as TextView).setTextColor(Color.parseColor(it)) }
            }
            "image_view" -> view = ImageView(context)
            "media_view" -> view = MediaView(context)
            "rating_bar" -> view = RatingBar(context)
            "button_view" -> view = Button(context)
        }

        (data["backgroundColor"] as? String)?.let { view.setBackgroundColor(Color.parseColor(it)) }

        val layoutParams = view.layoutParams ?: LayoutParams(-1, -1, 0f)
        (data["height"] as? Double)?.let { layoutParams.height = it.toInt() }
        (data["width"] as? Double)?.let { layoutParams.width = it.toInt() }
        view.layoutParams = layoutParams

        when (data["id"] as String) {
            "advertiser" -> adAdvertiser = view as TextView
            "attribuition" -> adAttribution = view as TextView
            "body" -> adBody = view as TextView
            "button" -> callToAction = view as Button
            "headline" -> adHeadline = view as TextView
            "icon" -> adIcon = view as ImageView
            "media" -> adMedia = view as MediaView
            "price" -> adPrice = view as TextView
            "ratingBar" -> ratingBar = view as RatingBar
            "store" -> adStore = view as TextView
        }

        return view
    }

    init {
        val inflater = LayoutInflater.from(context)
//        val layout = when (type) {
//            NativeAdmobType.full -> R.layout.native_admob_full_view
//            NativeAdmobType.banner -> R.layout.native_admob_banner_view
//        }
        val layout = R.layout.ad_unified_native_ad
        val viewRoot = inflater.inflate(layout, this, true)

        setBackgroundColor(Color.TRANSPARENT)

        adView = viewRoot.findViewById(R.id.native_ad_view)

        build(data)

        // The MediaView will display a video asset if one is present in the ad, and the
        // first image asset otherwise.
        adView.mediaView = adMedia

        // Register the view used for each individual asset.
        adView.headlineView = adHeadline
        adView.bodyView = adBody
        adView.callToActionView = callToAction
        adView.iconView = adIcon
        adView.priceView = adPrice
        adView.starRatingView = ratingBar
        adView.storeView = adStore
        adView.advertiserView = adAdvertiser
    }

    fun setNativeAd(nativeAd: UnifiedNativeAd?) {
        if (nativeAd == null) return

        // Some assets are guaranteed to be in every UnifiedNativeAd.
        adMedia?.setMediaContent(nativeAd.mediaContent)
        adMedia?.setImageScaleType(ImageView.ScaleType.FIT_CENTER)

        adHeadline?.text = nativeAd.headline
        adBody?.text = nativeAd.body
        (adView.callToActionView as Button).text = nativeAd.callToAction

        // These assets aren't guaranteed to be in every UnifiedNativeAd, so it's important to
        // check before trying to display them.
        val icon = nativeAd.icon

        if (icon == null) {
            adView.iconView.visibility = View.GONE
        } else {
            (adView.iconView as ImageView).setImageDrawable(icon.drawable)
            adView.iconView.visibility = View.VISIBLE
        }

        if (nativeAd.price == null) {
            adPrice?.visibility = View.INVISIBLE
        } else {
            adPrice?.visibility = View.VISIBLE
            adPrice?.text = nativeAd.price
        }

        if (nativeAd.store == null) {
            adStore?.visibility = View.INVISIBLE
        } else {
            adStore?.text = nativeAd.store
        }

        if (nativeAd.starRating == null) {
            adView.starRatingView.visibility = View.INVISIBLE
        } else {
            (adView.starRatingView as RatingBar).rating = nativeAd.starRating!!.toFloat()
            adView.starRatingView.visibility = View.VISIBLE
        }

        if (nativeAd.advertiser == null) {
            adAdvertiser?.visibility = View.INVISIBLE
        } else {
            adAdvertiser?.visibility = View.VISIBLE
            adAdvertiser?.text = nativeAd.advertiser
        }

        // Assign native ad object to the native view.
        adView.setNativeAd(nativeAd)
    }
}