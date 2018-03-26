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
        
        initPlayer()
        
    }
    
    func initPlayer()  {
        guard let url = URL(string: "http://ws.stream.qqmusic.qq.com/C100001JITda3sTVCc.m4a?fromtag=38") else {return}
        let player = Zany(url: url, observer: { [weak self] (zany, progress) -> (Void) in
            guard let unwrapped = self  else{ return }
//            print("\(zany.id)---\(progress)")
//            print("unwrapped.playerItem---\(String(describing: unwrapped.playerItem))")
        
            }, ItemAddObserver: { [weak self] (zany, item) -> (Void) in
                // add observer for AVPlayerItem
                          print("add observer ")
                guard let unwrapped = self  else{ return }
                item.addObserver(unwrapped, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
                unwrapped.playerItem = item
        }) { [weak self] (zany, item) -> (Void) in
            // remove observer
//            print("remove observer")
            
            guard let unwrapped = self  else{ return }
            item.removeObserver(unwrapped, forKeyPath: "status")
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
    
    @objc func didPlayBtn()  {
        
         initPlayer()
        
//
//        if playerInstance?.state == .running {
//            playerInstance?.pause()
//        }else{
//            playerInstance?.play()
//        }
//
        
        
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

