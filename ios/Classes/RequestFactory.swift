import GoogleMobileAds

public enum RequestFactory {
    public static func createAdRequest(nonPersonalizedAds: Bool, keywords: [String]? = nil) -> GADRequest {
        let request = GADRequest()
        if nonPersonalizedAds {
            let extras = GADExtras()
            extras.additionalParameters = ["npa": "1"]
            request.register(extras)
        }
        if #available(iOS 13.0, *) {
            request.scene = UIApplication.shared.keyWindow?.windowScene
        }
        if keywords != nil {
            request.keywords = keywords
        }
        return request
    }
}
