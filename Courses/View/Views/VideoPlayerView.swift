//
//  VideoPlayerView.swift
//  Courses
//
//  Created by Руслан on 24.12.2024.
//

import UIKit
import AVKit

class VideoPlayerView: UIView {
    
    var player: AVPlayer? {
           didSet {
               playerViewController.player = player
           }
       }
   
    
    private let playerViewController = AVPlayerViewController()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPlayerView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlayerView()
    }
    
    private func setupPlayerView() {
        
         if let parentVC = findViewController() {
            parentVC.addChild(playerViewController)

            playerViewController.view.frame = self.bounds
            playerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(playerViewController.view)
            playerViewController.didMove(toParent: parentVC)
          }
    }
    
    func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while (responder != nil) {
            responder = responder!.next
            if (responder is UIViewController) {
                return responder as? UIViewController
            }
        }
        return nil
    }

    deinit {
       player?.pause()
    }
}
