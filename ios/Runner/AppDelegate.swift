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
    // Albums platform channel
    let albumsChannel = FlutterMethodChannel(name: "picsor.albums", binaryMessenger: controller.binaryMessenger)
    albumsChannel.setMethodCallHandler { (call, result) in
      if call.method == "addToAlbum" {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String,
              let albumName = args["album"] as? String else {
          result(false)
          return
        }
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        guard let asset = assets.firstObject else {
          result(false)
          return
        }
        // Find or create album
        var albumPlaceholder: PHObjectPlaceholder?
        var albumCollection: PHAssetCollection?
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let found = collections.firstObject {
          albumCollection = found
        }
        PHPhotoLibrary.shared().performChanges({
          if albumCollection == nil {
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
          }
        }, completionHandler: { success, error in
          if !success {
            result(false)
            return
          }
          // Fetch (possibly newly created) album
          let fetchOptions = PHFetchOptions()
          fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
          let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
          guard let album = collections.firstObject else {
            result(false)
            return
          }
          // Add asset to album
          PHPhotoLibrary.shared().performChanges({
            if let changeRequest = PHAssetCollectionChangeRequest(for: album) {
              let assetsArray = NSArray(object: asset)
              changeRequest.addAssets(assetsArray)
            }
          }, completionHandler: { addSuccess, addError in
            result(addSuccess)
          })
        })
      } else if call.method == "getAlbums" {
        let fetchOptions = PHFetchOptions()
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        var albumNames: [String] = []
        collections.enumerateObjects { (collection, _, _) in
          albumNames.append(collection.localizedTitle ?? "")
        }
        result(albumNames)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
