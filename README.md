[![Swift 5.0](https://img.shields.io/badge/swift-5.0-ED523F.svg?style=flat)](https://swift.org/download/)
[![Platform](https://img.shields.io/cocoapods/p/SwiftyAds.svg?style=flat)]()
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SwiftyAds.svg)](https://img.shields.io/cocoapods/v/SwiftyAds.svg)

# SwiftyAds

A Swift library to display banner, interstitial, rewarded videos and native ads from Google AdMob and supported mediation partners.

# 2021 Roadmap

- Multiple ad unit ids
- Swift package manager support

## Requirements

- iOS 11.4+
- Swift 5.0+

## Create AdMob account

Sign up for an [AdMob account](https://admob.google.com/home/get-started/) and create your required adUnitIDs for the types of ads you would like to display. 

## Mediation

[READ](https://developers.google.com/admob/ios/mediation)

## ATT and GDPR

SwiftyAds use Google`s [UMP](https://developers.google.com/admob/ump/ios/quick-start) (User Messaging Platform) SDK to handle user consent. This SDK handles both GDPR requests and also the iOS 14 ATT alert if required. Please read the Funding Choices [documentation](https://support.google.com/fundingchoices/answer/9180084) to ensure they are setup up correctly for ATT and GDPR.

## Installation

### Cocoa Pods

[CocoaPods](https://developers.google.com/admob/ios/quick-start#streamlined_using_cocoapods) is a dependency manager for Cocoa projects. 
Simply install the pod by adding the following line to your pod file

```swift
pod 'SwiftyAds'
```

### Manually 

Alternatively you can copy the `Sources` folder and its containing files into your project. Install the required dependencies either via Cocoa Pods.

```swift
pod 'Google-Mobile-Ads-SDK'
```

or manually

- [AdMob](https://developers.google.com/admob/ios/quick-start#manual_download)
- [UMP](https://developers.google.com/admob/ump/ios/quick-start#manual_download)

## Usage

### Update Info.plist

- [AdMob](https://developers.google.com/admob/ios/quick-start#update_your_infoplist)
- [UMP](https://developers.google.com/admob/ump/ios/quick-start#update_your_infoplist)

### Add SwiftyAds.plist

Download the template plist and add it to your projects main bundle. Than enter your required ad unit ids and under age of consent setting. You can remove unused ad unit ids from the plist as they are optional.

[Template ](Downloads/SwiftyAdsPlistTemplate.zip)

### Link AppTrackingTransparency framework

[Link](https://developers.google.com/admob/ump/ios/quick-start#update_your_infoplist) the AppTrackingTransparency framework otherwise ATT alerts will not display.

### Setup 

Create a setup method and call it as soon as your app launches e.g. AppDelegate `didFinishLaunchingWithOptions`. This will also trigger the initial consent flow (GDPR and ATT).

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    if let rootViewController = window?.rootViewController {
        setupSwiftyAds(from: rootViewController)
    }
    return true
}

private func setupSwiftyAds(from viewController: UIViewController) {
    #if DEBUG
    let environment: SwiftyAdsEnvironment = .debug(testDeviceIdentifiers: [], geography: .disabled, resetConsentInfo: true)
    #else
    let environment: SwiftyAdsEnvironment = .production
    #endif
    
    SwiftyAds.shared.setup(
        from: viewController,
        for: environment,
        consentStatusDidChange: { status in
            print("The consent status has changed: \(status)")
        },
        completion: { result in
            switch result {
            case .success(let consentStatus):
                print("Setup successful with consent status: \(consentStatus)")
            case .failure(let error):
                print("Setup error: \(error)")
            }
        }
    )
}
```

### Showing ads outside a UIViewController

SwiftyAds requires reference to a `UIViewController` to present ads. If you are not using SwiftyAds inside a `UIViewController` you can do the following to get reference the rootViewController.

AppDelegate
```swift
if let viewController = window?.rootViewController {
    SwiftyAds.shared.show(...)
}
```

SKScene
```swift
if let viewController = view?.window?.rootViewController {
    SwiftyAds.shared.show(...)
}
```

### Banner Ads

Create a property in your `UIViewController` for the banner to be displayed

```swift
class SomeViewController: UIViewController {

    private var bannerAd: SwiftyAdsBannerType?
}
```

Prepare the banner in `viewDidLoad`

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    bannerAd = SwiftyAds.shared.makeBannerAd(
        in: self,
        adUnitIdType: .plist, // set to .custom to add a different AdUnitId
        position: .bottom(isUsingSafeArea: true) // banner is pinned to bottom and follows safe area layout guide
        animationDuration: 1.5,
        onOpen: ({
            print("SwiftyAds banner ad did open")
        }),
        onClose: ({
            print("SwiftyAds banner ad did close")
        }),
        onError: ({ error in
            print("SwiftyAds banner ad error \(error)")
        })
    )
}
```

and show it in `viewDidAppear`. This is to ensure that the view has been layed out correctly and has a valid safe area.

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    bannerAd?.show(isLandscape: view.frame.width > view.frame.height)
}
```

To handle orientation changes, simply call the show method again in `viewWillTransition`

```swift
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    coordinator.animate(alongsideTransition: { [weak self] _ in
        self?.bannerAd?.show(isLandscape: size.width > size.height)
    })
}
```

You can hide the banner by calling the `hide` method. 

```swift
bannerAd?.hide(animated: true) 
```

You can remove the banner from its superview by calling the `remove` method and afterwards nil out the reference.

```swift
bannerAd?.remove() 
bannerAd = nil
```

### Interstitial Ads

```swift
SwiftyAds.shared.showInterstitialAd(
    from: self,
    afterInterval: 2, // every 2nd time method is called ad will be displayed
    onOpen: ({
        print("SwiftyAds interstitial ad did open")
    }),
    onClose: ({
        print("SwiftyAds interstitial ad did close")
    }),
    onError: ({ error in
        print("SwiftyAds interstitial ad error \(error)")
    })
)
```

### Rewarded Ads

Always use a dedicated button to display rewarded videos. You should never show them automatically as some might be non-skippable.

AdMob provided a new rewarded video API which lets you preload multiple rewarded videos with different AdUnitIds. While SwiftyAds uses this new API it currently only supports loading 1 rewarded video ad at a time.

```swift
SwiftyAds.shared.showRewardedAd(
    from: self,
    onOpen: ({
        print("SwiftyAds rewarded video ad did open")
    }),
    onClose: ({
        print("SwiftyAds rewarded video ad did close")
    }), 
    onError: ({ error in
        print("SwiftyAds rewarded video ad error \(error)")
    }),
    onNotReady: ({ [weak self] in
        guard let self = self else { return }
        print("SwiftyAds rewarded video ad was not ready")
        // If the user presses the rewarded video button and watches a video it might take a few seconds for the next video to reload.
        // Use this callback to display an alert incase the video was not ready. 
        let alertController = UIAlertController(
            title: "Sorry",
            message: "No video available to watch at the moment.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel))
        self.present(alertController, animated: true)
    }),
    onReward: ({ [weak self] rewardAmount in
        print("SwiftyAds rewarded video ad did reward user with \(rewardAmount)")
        // Provide the user with the reward e.g coins, diamonds etc
    })
)
```

### Native Ads

To present a native ad simply call the load method. Once a native ad has been received you can update your custom ad view with the native ad content.

You can set the amount of ads to load (`GADMultipleAdsAdLoaderOptions`) via the count parameter. Set to nil to use default options.

As per Googles documentation, requests for multiple native ads don't currently work for AdMob ad unit IDs that have been configured for mediation. Publishers using mediation should avoid using the GADMultipleAdsAdLoaderOptions class when making requests. In that case you can also set the count parameter to nil.


```swift
SwiftyAds.shared.loadNativeAd(
    from: self,
    adUnitIdType: .plist, // set to .custom to add a different AdUnitId
    count: nil,
    onReceive: { nativeAd in
        // show native ad (see demo app or google documentation)
    },
    onError: { error in
        // handle error
    }
)
```

Note: While prefetching ads is a great technique, it's important that you don't keep old native ads around forever without displaying them. Any native ad objects that have been held without display for longer than an hour should be discarded and replaced with new ads from a new request.


### Consent Status/Type

```swift
// Check current consent status
SwiftyAds.shared.consentStatus

// Check type of consent provided
SwiftyAds.shared.consentType
```

### Booleans

```swift
// Check if rewarded video is ready, for example to show/hide button
SwiftyAds.shared.isRewardedAdReady

// Check if interstitial ad is ready, for example to show an alternative ad
SwiftyAds.shared.isInterstitialAdReady
```

### Disable Ads (In App Purchases)

Call the `disable()` method and banner and interstitial ads will no longer display. 
This will not stop rewarded videos from displaying as they should have a dedicated button. This way you can remove banner and interstitial ads but still have rewarded videos. 

```swift
SwiftyAds.shared.disable()
```

For permanent storage you will need to create your own boolean logic and save it in something like `NSUserDefaults`, or preferably `Keychain`. 
Than at app launch, after you have called `SwiftyAds.shared.setup(...)`, check your saved boolean and disable the ads if required.

```swift
if UserDefaults.standard.bool(forKey: "RemovedAdsKey") == true {
    SwiftyAds.shared.disable()
}
```

### Ask for consent again

It is required that the user has the option to change their GDPR consent settings, usually via a button in settings. 

```swift
func consentButtonPressed() {
    SwiftyAds.shared.askForConsent(from: self) { result in
        switch result {
        case .success(let status):
            print("Did change consent status to \(status)")
        case .failure(let error):
            print("Consent status change error \(error)")
        }
    }
}
```

The consent button can be hidden if consent is not required.

```swift
consentButton.isHidden = SwiftyAds.shared.consentStatus == .notRequired
```
