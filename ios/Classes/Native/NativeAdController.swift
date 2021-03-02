import Flutter
import GoogleMobileAds

class NativeAdController: NSObject,GADNativeAdLoaderDelegate {

    var nativeAdChanged: ((GADNativeAd?) -> Void)? = nil
    var nativeAdUpdateRequested: ((Dictionary<String, Any>?, GADNativeAd?) -> Void)? = nil
    var nativeAd: GADNativeAd? = nil
    var adLoader: GADAdLoader!

    
    let id: String
    let channel: FlutterMethodChannel
    
    init(id: String, channel: FlutterMethodChannel) {
        self.id = id
        self.channel = channel
        super.init()
        
        self.nativeAdChanged={ (ad: GADNativeAd?) -> Void in
            self.nativeAd=ad}
        
        channel.setMethodCallHandler(handle)
    }
    
    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let params = call.arguments as? [String: Any]

        switch call.method {
        case "loadAd" :
            let unitId: String = params?["unitId"] as! String
            let options: Dictionary<String, Any> = params?["options"] as! Dictionary<String, Any>
            loadAd(unitId: unitId, options: options, result: result)
            
        case "updateUI":
            if(params?["layout"]==nil || nativeAdUpdateRequested == nil){return}
            let layout: Dictionary<String, Any> = params?["layout"] as! Dictionary<String, Any>
            nativeAdUpdateRequested!(layout,nativeAd)
            result(nil)
            
        case "muteAd":
            // yep it's always success :)
            if (nativeAd == nil) {return result(nil)}
            if ((nativeAd?.isCustomMuteThisAdAvailable) != nil){
                nativeAd?.muteThisAd(with: nativeAd?.muteThisAdReasons![params?["reason"] as! Int])
            }
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func loadAd(unitId: String, options: Dictionary<String, Any>, result: FlutterResult) {
        self.channel.invokeMethod("loading", arguments: nil)
            // ad options
        let adImageAdLoaderOptions = GADNativeAdImageAdLoaderOptions()
        adImageAdLoaderOptions.shouldRequestMultipleImages=options["requestMultipleImages"] as! Bool
        let adViewAdOptions = GADNativeAdViewAdOptions()
        adViewAdOptions.preferredAdChoicesPosition=GADAdChoicesPosition(rawValue: options["adChoicesPlacement"] as! Int)!
        let adVideoOptions = GADVideoOptions()
        adVideoOptions.startMuted=(options["videoOptions"] as! Dictionary<String, Any>)["startMuted"] as! Bool
        let adMediaAdLoaderOptions = GADNativeAdMediaAdLoaderOptions()
        adMediaAdLoaderOptions.mediaAspectRatio=GADMediaAspectRatio(rawValue: options["mediaAspectRatio"] as! Int)!
        let adMuteThisAdLoaderOptions=GADNativeMuteThisAdLoaderOptions()
        adMuteThisAdLoaderOptions.customMuteThisAdRequested=options["requestCustomMuteThisAd"] as! Bool

        
        adLoader = GADAdLoader(adUnitID: unitId, rootViewController: nil, adTypes: [ GADAdLoaderAdType.native ], options: [adImageAdLoaderOptions,adViewAdOptions,adVideoOptions,adMediaAdLoaderOptions,adMuteThisAdLoaderOptions
        ])
        adLoader.delegate=self
        adLoader.load(GADRequest())
        }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        nativeAd.rootViewController=UIApplication.shared.keyWindow?.rootViewController
        if(self.nativeAdChanged != nil){ self.nativeAdChanged!(nativeAd)}
        let mediaContent = nativeAd.mediaContent

        self.channel.invokeMethod("onAdLoaded", arguments: [
            "muteThisAdInfo" :[
                "muteThisAdReasons" : nativeAd.muteThisAdReasons?.map{
                    $0.description
                } ?? [""],
                "isCustomMuteThisAdEnabled" : nativeAd.isCustomMuteThisAdAvailable
            ],
            "mediaContent" :[
                "duration" : Double(mediaContent.duration),
                "aspectRatio" : Double(mediaContent.aspectRatio),
                "hasVideoContent" : mediaContent.hasVideoContent
            ]
        ]
        )
        
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        self.channel.invokeMethod("onAdFailedToLoad", arguments: error.localizedDescription)
    }
    
   
    
}
