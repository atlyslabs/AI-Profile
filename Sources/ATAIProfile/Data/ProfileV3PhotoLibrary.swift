import CoreLocation
import Foundation
import Photos

struct ProfileV3PhotoLibrary: ProfileV3PhotoLibraryReading {
    var access: ProfileV3PhotoAccess {
        Self.access(PHPhotoLibrary.authorizationStatus(for: .readWrite))
    }

    func requestAccess() async -> ProfileV3PhotoAccess {
        Self.access(await PHPhotoLibrary.requestAuthorization(for: .readWrite))
    }

    func tally(takenAfter date: Date?) async throws -> ProfileV3PhotoPlaceTally {
        let options = PHFetchOptions()
        options.includeAssetSourceTypes = [.typeUserLibrary, .typeiTunesSynced]
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        if let date {
            options.predicate = NSPredicate(format: "creationDate > %@", date as NSDate)
        }
        let assets = PHAsset.fetchAssets(with: .image, options: options)
        var tally = ProfileV3PhotoPlaceTally()
        for index in 0..<assets.count {
            if index.isMultiple(of: 500) { try Task.checkCancellation() }
            let asset = assets.object(at: index)
            tally.noteScanned(takenAt: asset.creationDate)
            guard let coordinate = asset.location?.coordinate, CLLocationCoordinate2DIsValid(coordinate) else { continue }
            tally.record(latitude: coordinate.latitude, longitude: coordinate.longitude, takenAt: asset.creationDate)
        }
        return tally
    }

    private static func access(_ status: PHAuthorizationStatus) -> ProfileV3PhotoAccess {
        switch status {
        case .authorized: return .full
        case .limited: return .limited
        case .notDetermined: return .notDetermined
        case .denied, .restricted: return .denied
        @unknown default: return .denied
        }
    }
}
