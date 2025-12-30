//
//  TrackPlayerService.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 30.12.2025.
//

import Foundation
import AVFoundation

protocol TrackPlayerServiceProtocol: AnyObject {
    var playerVolume: Float { get set }
    var timeControlStatus: AVPlayer.TimeControlStatus { get }
    
    func replaceAndPlay(previewUrl: URL?)
    func play()
    func pause()
    func seek(to time: CMTime)
    
    @discardableResult
    func addBoundaryTimeObserver(
        forTimes times: [NSValue],
        queue: DispatchQueue?,
        using block: @escaping () -> Void
    ) -> Any
    
    @discardableResult
    func addPeriodicTimeObserver(
        forInterval interval: CMTime,
        queue: DispatchQueue?,
        using block: @escaping (CMTime) -> Void
    ) -> Any
    
    func removeTimeObserver(_ observer: Any)
    
    var currentItemDuration: CMTime? { get }
    func currentTime() -> CMTime
}

final class TrackPlayerService: TrackPlayerServiceProtocol {
    
    private let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    var playerVolume: Float {
        get { player.volume }
        set { player.volume = newValue }
    }
    
    var timeControlStatus: AVPlayer.TimeControlStatus {
        player.timeControlStatus
    }
    
    var currentItemDuration: CMTime? {
        player.currentItem?.duration
    }
    
    func currentTime() -> CMTime {
        player.currentTime()
    }
    
    func replaceAndPlay(previewUrl: URL?) {
        guard let url = previewUrl else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func seek(to time: CMTime) {
        player.seek(to: time)
    }
    
    func addBoundaryTimeObserver(
        forTimes times: [NSValue],
        queue: DispatchQueue?,
        using block: @escaping () -> Void
    ) -> Any {
        player.addBoundaryTimeObserver(forTimes: times, queue: queue, using: block)
    }
    
    func addPeriodicTimeObserver(
        forInterval interval: CMTime,
        queue: DispatchQueue?,
        using block: @escaping (CMTime) -> Void
    ) -> Any {
        player.addPeriodicTimeObserver(forInterval: interval, queue: queue, using: block)
    }
    
    func removeTimeObserver(_ observer: Any) {
        player.removeTimeObserver(observer)
    }
}
