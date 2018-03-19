//
//  ZanyTests.swift
//  ZanyTests
//
//  Created by 周逸文 on 2018/3/18.
//  Copyright © 2018年 YV. All rights reserved.
//

import XCTest
import Zany
//import Foundation

class ZanyTests: XCTestCase {
    
    private var playerInstance: Any? = nil
    
    
    func test_simplePlay() {
        let exp = expectation(description: "test_simplePlay")
        
        guard let url = URL(string: "http://ws.stream.qqmusic.qq.com/C100001JITda3sTVCc.m4a?fromtag=38") else {return}
        let player = Zany(url: url)
        player.onStateChanged = { (_,state) in
            
            switch state {
            case .running:
                print("running")
                player.pause()
            case .paused:
                print("paused")
                player.testFinished()
            case .finished:
                print("finished")
                exp.fulfill()
            }
        }
 
        player.play()
        
        self.playerInstance = player
        self.wait(for: [exp], timeout: 10)
    }
    
  
    
}
