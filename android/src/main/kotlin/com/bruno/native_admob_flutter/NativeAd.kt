package com.bruno.native_admob_flutter

import android.content.Context
import android.content.res.Resources
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.*
import android.graphics.drawable.GradientDrawable.*
import android.os.Build
import android.view.*
import android.widget.*
import android.widget.LinearLayout.HORIZONTAL
import android.widget.LinearLayout.VERTICAL
import com.google.android.gms.ads.formats.*
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        return NativeAdView(context, creationParams)
    }

}

class NativeAdView(context: Context, data: Map<String?, Any?>?) : PlatformView {
    private val adView: UnifiedNativeAdView

    private var ratingBar: RatingBar? = RatingBar(context)

    private var adMedia: MediaView? = MediaView(context)
    private var adIcon: ImageView? = ImageView(context)

    private var adHeadline: TextView? = TextView(context)
    private var adAdvertiser: TextView? = TextView(context)
    private var adBody: TextView? = TextView(context)
    private var adPrice: TextView? = TextView(context)
    private var adStore: TextView? = TextView(context)
    private var adAttribution: TextView? = TextView(context)
    private var callToAction: Button? = Button(context)

    private fun build(data: Map<*, *>, context: Context): View {
        return buildView(data, context)
    }

    private fun buildView(data: Map<*, *>, context: Context): View {
        val viewType: String = data["viewType"] as String
        var view = View(context)
        when (viewType) {
            "linear_layout" -> {
                view = LinearLayout(context)
                view.orientation = if (data["orientation"] as String == "vertical")
                    VERTICAL
                else HORIZONTAL

                view.gravity = Gravity.TOP

                if (data["children"] != null)
                    for (child in data["children"] as List<*>)
                        view.addView(buildView(child as Map<*, *>, context))
            }
            "text_view" -> {
                view = TextView(context)
                (data["textSize"] as? Double?)?.toFloat()?.also { (view as TextView).textSize = it }
                (data["textColor"] as? String)?.let { (view as TextView).setTextColor(Color.parseColor(it)) }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    (data["letterSpacing"] as? Double)?.let { (view as TextView).letterSpacing = it.toFloat() }
                }
                (data["maxLines"] as? Int?)?.also { (view as TextView).maxLines = it }
                (data["minLines"] as? Int?)?.also { (view as TextView).minLines = it }
                (data["bold"] as? Boolean)?.let {
                    if (it) (view as TextView).setTypeface((view as TextView).typeface, Typeface.BOLD)
                }
                (data["text"] as? String)?.let { (view as TextView).text = it }
            }
            "image_view" -> {
                view = ImageView(context)
                view.adjustViewBounds = true
            }
            "media_view" -> {
                view = MediaView(context)
                view.setImageScaleType(ImageView.ScaleType.FIT_START)
            }
            "rating_bar" -> view = RatingBar(context)
            "button_view" -> {
                view = Button(context)
//                val foreground = GradientDrawable()
//                (data["pressColor"] as? String)?.let { foreground.setColor(Color.parseColor(it)) }
//                view.isClickable = true
//                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
//                    view.foreground = foreground
//                }
            }
        }

        var shape = GradientDrawable()

        (data["gradient"] as? Map<String, Any>)?.let { data ->

            val orientation: Orientation = when (data["orientation"]) {
                "top_bottom" -> Orientation.TOP_BOTTOM
                "tr_bl" -> Orientation.TR_BL
                "right_left" -> Orientation.RIGHT_LEFT
                "br_tl" -> Orientation.BR_TL
                "bottom_top" -> Orientation.BOTTOM_TOP
                "bl_tr" -> Orientation.BL_TR
                "left_right" -> Orientation.LEFT_RIGHT
                "tl_br" -> Orientation.TL_BR
                else -> Orientation.LEFT_RIGHT
            }

            val colors: List<Int> = (data["colors"] as List<String>).map { Color.parseColor(it) };

            shape = GradientDrawable(orientation, colors.toIntArray())

            when (data["type"]) {
                "linear" -> {} // Already implemented it above
                "radial" -> {
                    shape.gradientType = RADIAL_GRADIENT
                    shape.gradientRadius = (data["radialGradientRadius"] as Double).toFloat()
                    shape.setGradientCenter(
                        (data["radialGradientCenterX"] as Double).toFloat(),
                        (data["radialGradientCenterX"] as Double).toFloat()
                    )
                }
                else -> {}
            }
        }

        // radius
        val topRight = ((data["topRightRadius"] as? Double) ?: 0.0).toFloat()
        val topLeft = ((data["topLeftRadius"] as? Double) ?: 0.0).toFloat()
        val bottomRight = ((data["bottomRightRadius"] as? Double) ?: 0.0).toFloat()
        val bottomLeft = ((data["bottomLeftRadius"] as? Double) ?: 0.0).toFloat()
        shape.cornerRadii = floatArrayOf(
                topLeft, topLeft,
                topRight, topRight,
                bottomRight, bottomRight,
                bottomLeft, bottomLeft)

        (data["backgroundColor"] as? String)?.let { shape.setColor(Color.parseColor(it)) }

        (data["borderWidth"] as? Double)?.let {
            val color: String = (data["borderColor"] as? String?) ?: "#FFFFFF"
            shape.setStroke(it.toInt().dp(), Color.parseColor(color))
        }
//        (data["backgroundColor"] as? String)?.let { view.setBackgroundColor(Color.parseColor(it)) }

        view.background = shape

        val layoutParams = view.layoutParams ?: LinearLayout.LayoutParams(-1, -1, 0f)
        val marginParams = (layoutParams as? ViewGroup.MarginLayoutParams)
                ?: ViewGroup.MarginLayoutParams(context, null)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            (data["marginRight"] as? Double)?.let { marginParams.rightMargin = it.toInt().dp() }
            (data["marginLeft"] as? Double)?.let { marginParams.leftMargin = it.toInt().dp() }
            (data["marginTop"] as? Double)?.let { marginParams.topMargin = it.toInt().dp() }
            (data["marginBottom"] as? Double)?.let { marginParams.bottomMargin = it.toInt().dp() }
        }
        view.layoutParams = marginParams
        view.requestLayout()

        val paddingRight = ((data["paddingRight"] as? Double) ?: 0.0).toInt().dp()
        val paddingLeft = ((data["paddingLeft"] as? Double) ?: 0.0).toInt().dp()
        val paddingTop = ((data["paddingTop"] as? Double) ?: 0.0).toInt().dp()
        val paddingBottom = ((data["paddingBottom"] as? Double) ?: 0.0).toInt().dp()

        view.setPadding(paddingLeft, paddingTop, paddingRight, paddingBottom)

        (data["height"] as? Double)?.let { marginParams.height = it.toInt().dp() }
        (data["width"] as? Double)?.let { marginParams.width = it.toInt().dp() }

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

    private var controller: NativeAdmobController? = null

    init {
        val inflater = LayoutInflater.from(context)
        val viewRoot = inflater.inflate(R.layout.ad_unified_native_ad, null)

        adView = viewRoot.findViewById(R.id.native_ad_view) as UnifiedNativeAdView
        adView.setBackgroundColor(Color.TRANSPARENT)

        val view: View = build(data!!, context)
        adView.addView(view)

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

        (data["controllerId"] as? String)?.let { id ->
            val controller = NativeAdmobControllerManager.getController(id)
            controller?.nativeAdChanged = { setNativeAd(it) }
            this.controller = controller
            println("controller attached $id")
        }

        controller?.nativeAd?.let {
            setNativeAd(it)
        }

    }

    private fun setNativeAd(nativeAd: UnifiedNativeAd?) {
        if (nativeAd == null) return

        println("setting native ad")

        // Some assets are guaranteed to be in every UnifiedNativeAd.
        adMedia?.setMediaContent(nativeAd.mediaContent)
        adMedia?.setImageScaleType(ImageView.ScaleType.FIT_CENTER)

        adHeadline?.text = nativeAd.headline
        adBody?.text = nativeAd.body
        (adView.callToActionView as? Button?)?.text = nativeAd.callToAction

        // These assets aren't guaranteed to be in every UnifiedNativeAd, so it's important to
        // check before trying to display them.
        val icon = nativeAd.icon

        adView.iconView?.visibility = if (icon == null) View.GONE else View.VISIBLE
        (adView.iconView as? ImageView?)?.setImageDrawable(icon?.drawable)

        adPrice?.visibility = if (nativeAd.price == null) View.INVISIBLE else View.VISIBLE
        adPrice?.text = nativeAd.price

        adStore?.visibility = if (nativeAd.store == null) View.INVISIBLE else View.VISIBLE
        adStore?.text = nativeAd.store

        adView.starRatingView?.visibility = if (nativeAd.starRating == null) View.INVISIBLE else View.VISIBLE
        if (nativeAd.starRating != null)
            (adView.starRatingView as? RatingBar)?.rating = nativeAd.starRating!!.toFloat()

        adAdvertiser?.visibility = if (nativeAd.advertiser == null) View.INVISIBLE else View.VISIBLE
        adAdvertiser?.text = nativeAd.advertiser

        // Assign native ad object to the native view.
        adView.setNativeAd(nativeAd)

        println("native ad set")
    }

    override fun getView(): View {
        return adView
    }

    override fun dispose() {
        controller?.nativeAd?.destroy()
    }

}

fun Int.dp(): Int {
    if (this == -1 || this == -2) return this
    val density = Resources.getSystem().displayMetrics.density
    return (this * density).toInt()
}