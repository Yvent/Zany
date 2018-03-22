//
//  ViewController.swift
//  Zany
//
//  Created by 周逸文 on 2018/3/18.
//  Copyright © 2018年 YV. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {
    
    
    var playerInstance: Zany? = nil
    var playerItem: AVPlayerItem? = nil
    lazy var playBtn: UIButton = {
        let make = UIButton()
        make.backgroundColor = UIColor.red
        make.setTitle("play", for: .normal)
        make.setTitle("pause", for: .selected)
        return make
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playBtn.frame = CGRect(x: 30, y: 30, width: 60, height: 60)
        playBtn.addTarget(self, action: #selector(ViewController.didPlayBtn), for: .touchUpInside)
        self.view.addSubview(playBtn)
        
        guard let url = URL(string: "http://ws.stream.qqmusic.qq.com/C100001JITda3sTVCc.m4a?fromtag=38") else {return}
        let player = Zany(url: url, observer: { (zany, progress) -> (Void) in
            print("\(zany.id)---\(progress)")
        }, ItemAddObserver: { (zany, item) -> (Void) in
            // add observer for AVPlayerItem
            item.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            self.playerItem = item
        }) { (zany, item) -> (Void) in
            // remove observer
            item.removeObserver(self, forKeyPath: "status")
        }
        player.onStateChanged = { (_,state) in
            
            switch state {
            case .running:
                self.playBtn.isSelected = true
            case .paused:
                self.playBtn.isSelected = false
            case .finished:
                print("finished")
                
            }
            
        }
        player.play()
        
        playerInstance = player
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        playerInstance?.removeAll()
    }
    @objc func didPlayBtn()  {
        
        if playerInstance?.state == .running {
            playerInstance?.pause()
        }else{
            playerInstance?.play()
        }
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let item = object as? AVPlayerItem, let keyPath = keyPath, item == self.playerItem {
            
            if keyPath == "status"{
                if item.status == AVPlayerItemStatus.failed {
                    print("failed")
                }else if item.status == AVPlayerItemStatus.readyToPlay {
                    
                    print("readyToPlay")
                }
            }
        }
    }
    
}

