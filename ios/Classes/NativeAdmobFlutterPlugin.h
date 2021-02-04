#import <GoogleMobileAds/GoogleMobileAds.h>
#import <Flutter/Flutter.h>

@interface NativeAdmobFlutterPlugin : NSObject<FlutterPlugin>
@property(strong, nonatomic) GADAppOpenAd* appOpenAd;

- (void)requestAppOpenAd;
- (void)tryToPresentAd;
@end
