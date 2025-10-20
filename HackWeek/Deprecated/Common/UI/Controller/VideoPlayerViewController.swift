//
//  VideoPlayerViewController.swift
//  AINote
//
//  Created by user on 2024/8/20.
//

import UIKit
import AVKit
import Combine

class VideoPlayerViewController: AVPlayerViewController {

    var playFinishedHandler: ((VideoPlayerViewController) -> Void)?
    var dismissedHandler: (() -> Void)?
    
    private var orientationMask: UIInterfaceOrientationMask
    private var cancellable: AnyCancellable?
    
    init(orientationMask: UIInterfaceOrientationMask = .all) {
        self.orientationMask = orientationMask
        super.init(nibName: nil, bundle: nil)
        setupPlayerNotification()
    }
    
    required init?(coder: NSCoder) {
        self.orientationMask = .all
        super.init(coder: coder)
        setupPlayerNotification()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissedHandler?()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return orientationMask
    }
    
    private func setupPlayerNotification() {
        cancellable = NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .sink { [weak self] notification in
                guard let self = self,
                      let playerItem = self.player?.currentItem,
                      playerItem == notification.object as? AVPlayerItem else { return }
                self.playFinishedHandler?(self)
            }
    }

}


extension VideoPlayerViewController {
    
    public func play(with url: URL) {
        let player = AVPlayer(url: url)
        self.player = player
        self.showsPlaybackControls = true
        self.videoGravity = .resizeAspect
        player.play()
    }
}
