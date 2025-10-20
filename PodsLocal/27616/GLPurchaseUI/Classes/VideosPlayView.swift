//
//  VideosPlayView.swift
//  Mejor
//
//  Created by Martin on 2023/7/11.
//

import UIKit
import AVFoundation

class VideosPlayView: UIView {
    var firstVideoLoadHandler: (()->())?
    private(set) var firstVideoHasLoaded: Bool = false {
        didSet {
            if self.firstVideoHasLoaded && oldValue != self.firstVideoHasLoaded {
                self.firstVideoLoadHandler?()
            }
        }
    }
    
    enum Data {
//        case remote(urlString: String)
        case local(path: String)
    }
    
    private(set) var index: Int = 0
    var handler: ((_ index: Int)->())?
    private var datas: [VideosPlayView.Data]!
    private(set) var isPlaying: Bool = false
    private var shouldPlay: Bool = false
    private let repeated: Bool
    
    public override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    private(set) var player: AVPlayer? {
        get {
            return self.playerLayer.player
        }
        
        set {
            self.playerLayer.player = newValue
        }
    }
    
    init() {
        self.repeated = true
        super.init(frame: .zero)
        let bundle = Bundle(for: type(of: self))
        if let path = bundle.path(forResource: "27584", ofType: "mp4") {
            self.datas = [.local(path: path)]
            self.addObserver()
            self.playerLayer.videoGravity = .resizeAspectFill
            self.load(index: 0, completion: nil)
            self.play()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func play(index: Int) {
        self.shouldPlay = true
        self.load(index: index) {[weak self] url in
            guard let self = self else { return }
            if let url = url {
                if self.shouldPlay {
                    self.playUrl(url)
                }
                self.load(index: self.index + 1, completion: nil)
                self.firstVideoHasLoaded = true
            }
        }
    }
    
    private func playNext() {
        var index = self.index + 1
        if index >= self.datas.count {
            if !self.repeated {
                self.handler?(index)
                return
            }
            index = 0
        }
        
        if index == self.index && self.player != nil {
            self.player?.currentItem?.seek(to: CMTime(seconds: 0.0, preferredTimescale: 6000), completionHandler: {[weak self] _ in
                self?.player?.play()
            })
        } else {
            self.index = index
            self.play(index: index)
            self.handler?(index)
        }
    }
    
    private func playUrl(_ url: URL) {
        let asset = AVAsset(url: url)
        let playItem = AVPlayerItem(asset: asset)
        
        if self.player == nil {
            let player = AVPlayer(playerItem: playItem)
            player.actionAtItemEnd = AVPlayer.ActionAtItemEnd.pause
            self.player = player
        } else {
            self.player?.replaceCurrentItem(with: playItem)
        }
        self.player?.play()
        self.isPlaying = true
        self.player?.volume = 0.0
    }
    
    func prepareForLocal() {
        guard let data = self.datas.first else { return }
        if case .local(let name) = data {
            guard let path = Bundle.main.path(forResource: name, ofType: nil) else { return }
            let url = URL(fileURLWithPath: path)
            
            let asset = AVAsset(url: url)
            let playItem = AVPlayerItem(asset: asset)
            let player = AVPlayer(playerItem: playItem)
            player.actionAtItemEnd = AVPlayer.ActionAtItemEnd.pause
            self.player = player
            player.volume = 0.0
            playItem.seek(to: CMTime(seconds: 0.1, preferredTimescale: 6000), completionHandler: {_ in})
        }
    }
    
    func play() {
        self.shouldPlay = true
        if self.isPlaying { return }
        
        if self.player == nil {
            self.play(index: self.index)
            return
        }
        
        // 这一个已经播放完了
        if let player = self.player,
           let currentTime = player.currentItem?.currentTime().seconds,
           let totalTime = player.currentItem?.duration.seconds,
           abs(totalTime - currentTime) < 0.2 {
            self.play(index: self.index)
        } else {
            self.player?.play()
            self.isPlaying = true
        }
    }
    
    func pause() {
        self.player?.pause()
        self.isPlaying = false
        self.shouldPlay = false
    }
    
    func resignActive() {
        self.player?.pause()
        self.isPlaying = false
    }
    
    func becomeActive() {
        if self.shouldPlay && !self.isPlaying {
            self.play()
        }
    }
    
    private func load(index: Int, completion: ((_ url: URL?)->())?) {
        if self.datas.count <= index {
            completion?(nil)
            return
        }
        
        self.loadData(self.datas[index]) { url in
            completion?(url)
        }
    }
    
    private func addObserver() {
        let center = NotificationCenter.default
        center.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) {[weak self] notification in
            guard let self = self, let item = notification.object as? AVPlayerItem, item === self.player?.currentItem else { return }
            self.isPlaying = false
            self.playNext()
        }
        
        var isPlayingBeforerResignActive: Bool = self.isPlaying
        center.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            isPlayingBeforerResignActive = self.isPlaying
            self.resignActive()
        }
        
        center.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            if isPlayingBeforerResignActive {
                self?.becomeActive()
            }
        }
    }
    
    // MARK: - Readonly
    private var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
}
