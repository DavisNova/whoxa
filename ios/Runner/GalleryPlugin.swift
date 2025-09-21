import Flutter
import UIKit
import Photos

public class GalleryPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "gallery_plugin", binaryMessenger: registrar.messenger())
        let instance = GalleryPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getAllPhotos":
            getAllPhotos(result: result)
        case "getRecentPhotos":
            if let args = call.arguments as? [String: Any],
               let limit = args["limit"] as? Int {
                getRecentPhotos(limit: limit, result: result)
            } else {
                getRecentPhotos(limit: 50, result: result)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getAllPhotos(result: @escaping FlutterResult) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .authorized || status == .limited {
            fetchPhotos(limit: nil, result: result)
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self.fetchPhotos(limit: nil, result: result)
                    } else {
                        result([])
                    }
                }
            }
        } else {
            result([])
        }
    }
    
    private func getRecentPhotos(limit: Int, result: @escaping FlutterResult) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .authorized || status == .limited {
            fetchPhotos(limit: limit, result: result)
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self.fetchPhotos(limit: limit, result: result)
                    } else {
                        result([])
                    }
                }
            }
        } else {
            result([])
        }
    }
    
    private func fetchPhotos(limit: Int?, result: @escaping FlutterResult) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        if let limit = limit {
            fetchOptions.fetchLimit = limit
        }
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var photoPaths: [String] = []
        
        let group = DispatchGroup()
        
        assets.enumerateObjects { (asset, index, stop) in
            group.enter()
            
            let options = PHImageRequestOptions()
            options.version = .original
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { (data, dataUTI, orientation, info) in
                defer { group.leave() }
                
                if let data = data,
                   let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    
                    let fileName = "photo_\(Date().timeIntervalSince1970)_\(index).jpg"
                    let fileURL = documentsPath.appendingPathComponent(fileName)
                    
                    do {
                        try data.write(to: fileURL)
                        photoPaths.append(fileURL.path)
                    } catch {
                        print("Error saving photo: \(error)")
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            result(photoPaths)
        }
    }
}
