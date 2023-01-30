//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaPlayer
import OSLog

private let kContentKeySession = AVContentKeySession(keySystem: .fairPlayStreaming)

private let kResourceLoaderQueue = DispatchQueue(label: "ch.srgssr.player.resource_loader")
private let kContentKeySessionQueue = DispatchQueue(label: "ch.srgssr.player.content_key_session")

/// An item which stores its own custom resource loader delegate.
final class ResourceLoadedPlayerItem: AVPlayerItem {
    // swiftlint:disable:next weak_delegate
    private let resourceLoaderDelegate: AVAssetResourceLoaderDelegate

    init(url: URL, resourceLoaderDelegate: AVAssetResourceLoaderDelegate) {
        self.resourceLoaderDelegate = resourceLoaderDelegate
        let asset = AVURLAsset(url: url)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: kResourceLoaderQueue)
        // Provide same key as for a standard asset, see `AVPlayerItem.init(asset:)` documentation.
        super.init(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
    }
}

/// An asset representing content to be played.
public struct Asset {
    typealias NowPlayingInfo = [String: Any]

    private let type: `Type`
    private let metadata: Metadata?
    private let configuration: (AVPlayerItem) -> Void

    /// A simple asset playable from a URL.
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - metadata: The metadata associated with the asset.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The asset.
    public static func simple(
        url: URL,
        metadata: Metadata? = nil,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            type: .simple(url: url),
            metadata: metadata,
            configuration: configuration
        )
    }

    /// An asset loaded with custom resource loading. The scheme of the URL to be played has to be recognized by
    /// the associated resource loader delegate.
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - metadata: The metadata associated with the asset.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The asset.
    public static func custom(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        metadata: Metadata? = nil,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            type: .custom(url: url, delegate: delegate),
            metadata: metadata,
            configuration: configuration
        )
    }

    /// An encrypted asset loaded with a content key session.
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The content key session delegate to use.
    ///   - metadata: The metadata associated with the asset.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The asset.
    public static func encrypted(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        metadata: Metadata? = nil,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            type: .encrypted(url: url, delegate: delegate),
            metadata: metadata,
            configuration: configuration
        )
    }

    func playerItem() -> AVPlayerItem {
        let item = type.playerItem()
        configuration(item)
        return item
    }

    func nowPlayingInfo() -> NowPlayingInfo {
        var nowPlayingInfo = NowPlayingInfo()
        if let metadata {
            nowPlayingInfo[MPMediaItemPropertyTitle] = metadata.title
            nowPlayingInfo[MPMediaItemPropertyArtist] = metadata.subtitle
            nowPlayingInfo[MPMediaItemPropertyComments] = metadata.description
            if let image = metadata.image {
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            }
        }
        return nowPlayingInfo
    }
}

public extension Asset {
    /// Metadata associated with an asset.
    struct Metadata {
        /// Title.
        let title: String?
        /// Subtitle.
        let subtitle: String?
        /// Description.
        let description: String?
        /// Image.
        let image: UIImage?

        /// Create an asset metadata.
        public init(title: String? = nil, subtitle: String? = nil, description: String? = nil, image: UIImage? = nil) {
            self.title = title
            self.subtitle = subtitle
            self.description = description
            self.image = image
        }
    }

    private enum `Type` {
        case simple(url: URL)
        case custom(url: URL, delegate: AVAssetResourceLoaderDelegate)
        case encrypted(url: URL, delegate: AVContentKeySessionDelegate)

        private static var logger = Logger(category: "Asset")

        func playerItem() -> AVPlayerItem {
            switch self {
            case let .simple(url: url):
                return AVPlayerItem(url: url)
            case let .custom(url: url, delegate: delegate):
                return ResourceLoadedPlayerItem(
                    url: url,
                    resourceLoaderDelegate: delegate
                )
            case let .encrypted(url: url, delegate: delegate):
#if targetEnvironment(simulator)
                Self.logger.error("FairPlay-encrypted assets cannot be played in the simulator")
                return AVPlayerItem(url: url)
#else
                let asset = AVURLAsset(url: url)
                kContentKeySession.setDelegate(delegate, queue: kContentKeySessionQueue)
                kContentKeySession.addContentKeyRecipient(asset)
                kContentKeySession.processContentKeyRequest(withIdentifier: nil, initializationData: nil)
                return AVPlayerItem(asset: asset)
#endif
            }
        }
    }
}

extension Asset {
    static var loading: Self {
        // Provide a playlist extension so that resource loader errors are correctly forwarded through the resource loader.
        .custom(url: URL(string: "pillarbox://loading.m3u8")!, delegate: LoadingResourceLoaderDelegate())
    }

    static func failed(error: Error) -> Self {
        // Provide a playlist extension so that resource loader errors are correctly forwarded through the resource loader.
        .custom(url: URL(string: "pillarbox://failing.m3u8")!, delegate: FailedResourceLoaderDelegate(error: error))
    }
}

extension Asset: Equatable {
    public static func == (lhs: Asset, rhs: Asset) -> Bool {
        switch (lhs.type, rhs.type) {
        case let (.simple(url: lhsUrl), .simple(url: rhsUrl)):
            return lhsUrl == rhsUrl
        case let (.custom(url: lhsUrl, delegate: lhsDelegate), .custom(url: rhsUrl, delegate: rhsDelegate)):
            return lhsUrl == rhsUrl && lhsDelegate === rhsDelegate
        case let (.encrypted(url: lhsUrl, delegate: lhsDelegate), .encrypted(url: rhsUrl, delegate: rhsDelegate)):
            return lhsUrl == rhsUrl && lhsDelegate === rhsDelegate
        default:
            return false
        }
    }
}