import UIKit
import Flutter
import Photos

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "picsor.favorite", binaryMessenger: controller.binaryMessenger)
    channel.setMethodCallHandler { (call, result) in
      if call.method == "setFavorite" {
        guard #available(iOS 14, *),
              let args = call.arguments as? [String: Any],
              let id = args["id"] as? String,
              let favorite = args["favorite"] as? Bool else {
          result(false)
          return
        }
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        guard let asset = assets.firstObject else {
          result(false)
          return
        }
        PHPhotoLibrary.shared().performChanges({
          let req = PHAssetChangeRequest(for: asset)
          req.isFavorite = favorite
        }, completionHandler: { success, error in
          result(success)
        })
      } else if call.method == "isFavorite" {
        guard #available(iOS 14, *),
              let args = call.arguments as? [String: Any],
              let id = args["id"] as? String else {
          result(false)
          return
        }
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        guard let asset = assets.firstObject else {
          result(false)
          return
        }
        result(asset.isFavorite)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
