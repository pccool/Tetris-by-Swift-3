//
//  ViewController.swift
//  Tetris by Swift 3
//
//  Created by 赵国欣 on 17/3/6.
//  Copyright © 2017年 coolFog. All rights reserved.
//

import UIKit

// 导入 AVFoundation 是为了播放背景音乐
import AVFoundation

class ViewController: UIViewController, GameViewDelegate {
    
    
    
    let MARGINE: CGFloat = 10
    let BUTTON_SIZE: CGFloat = 48
    let BUTTON_ALPHA: CGFloat = 0.8
    let TOOLBAR_HEIGHT: CGFloat = 44
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var gameView: GameView!
    
    
    
    // 定义背景音乐的播放对象
    var bgMusicPlayer: AVAudioPlayer!
    // 定义显示当前速度的 UILabel
    var speedShow: UILabel!
    // 定义显示当前积分的 UILabel
    var scoreShow: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rect = UIScreen.main.bounds
        screenWidth = rect.size.width
        screenHeight = rect.size.height
        
        // 添加工具条
        self.addToolBar()
        // 创建 GameView 控件
        gameView = GameView(frame: CGRect(x: rect.origin.x + MARGINE,
                                          y: rect.origin.y + TOOLBAR_HEIGHT + MARGINE * 2,
                                          width: rect.size.width - MARGINE * 2,
                                          height: rect.size.height - 80))
        
        // 添加绘制游戏状态的自定义 View
        self.view.addSubview(gameView)
        // 设置代理
        gameView.delegate = self
        
        
        // 开始游戏
        gameView.startGame()
        // 添加游戏控制按钮
        self.addButtons()
        
        // 获取背景音效的音频文件的 URL
        let bgMusicURL = Bundle.main.url(forResource: "Smokers", withExtension: "mp3")
        // 创建 AVAudioPlayer 对象
        bgMusicPlayer = try! AVAudioPlayer(contentsOf: bgMusicURL!)
        bgMusicPlayer.numberOfLoops = -1
        //播放背景音效
        bgMusicPlayer.play()
        
    }
    
    // 定义在程序顶部添加工具条的方法
    func addToolBar() {
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: MARGINE * 2, width: screenWidth, height: TOOLBAR_HEIGHT))
        
        self.view.addSubview(toolBar)
        
        // 创建第一个显示"速度:"的标签
        let speedLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: TOOLBAR_HEIGHT))
        speedLabel.text = "速度:"
        let speedLabelItem = UIBarButtonItem(customView: speedLabel)
        
        // 创建第二个显示速度值的标签
        speedShow = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: TOOLBAR_HEIGHT))
        speedShow.textColor = UIColor.red
        let speedShowItem = UIBarButtonItem(customView: speedShow)
        
        // 创建第三个显示"当前积分:"的标签
        let scoreLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 90, height: TOOLBAR_HEIGHT))
        scoreLabel.text = "当前积分:"
        let scoreLabelItem = UIBarButtonItem(customView: scoreLabel)
        
        // 创建第四个显示积分值的标签
        scoreShow = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: TOOLBAR_HEIGHT))
        scoreShow.textColor = UIColor.red
        let scoreShowItem = UIBarButtonItem(customView: scoreShow)
        
        let flexItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // 为工具条设置工具项
        toolBar.items = [speedLabelItem, speedShowItem, flexItem, scoreLabelItem, scoreShowItem]
        
    }
    
    func addButtons() {
        
        // 定义4个按钮的 x 坐标
        let xArray = [screenWidth - BUTTON_SIZE * 3 - MARGINE,
                      screenWidth - BUTTON_SIZE * 2 - MARGINE,
                      screenWidth - BUTTON_SIZE * 1 - MARGINE,
                      screenWidth - BUTTON_SIZE * 2 - MARGINE]
        // 定义4个按钮的 y 坐标
        let yArray = [screenHeight - BUTTON_SIZE - MARGINE,
                      screenHeight - BUTTON_SIZE - MARGINE,
                      screenHeight - BUTTON_SIZE - MARGINE,
                      screenHeight - BUTTON_SIZE * 2 - MARGINE]
        // 定义4个按钮的图片
        let imageName = ["left", "down", "right", "up"]
        let selectors: [Selector] = [#selector(touchLeft), #selector(touchDown), #selector(touchRight), #selector(touchUp)]
        // 采用循环添加4个按钮
        for i in 0 ..< xArray.count { // var i = 0; i < xArray.count; i++
            // 创建按钮
            let bn = UIButton(type: .custom)
            // 设置按钮的大小、位置
            bn.frame = CGRect(x: xArray[i], y: yArray[i], width: BUTTON_SIZE, height: BUTTON_SIZE)
            bn.alpha = BUTTON_ALPHA
            
            bn.setImage(UIImage(named: "images/\(imageName[i])0.png"), for: .normal)
            bn.setImage(UIImage(named: "images/" + imageName[i] + "1"), for: .highlighted)
            self.view.addSubview(bn)
            bn.addTarget(self, action: selectors[i], for: .touchUpInside)
        }
        
    }
    
    
    // 向左
    func touchLeft() {
        gameView.moveLeft()
    }
    // 向下
    func touchDown() {
        gameView.moveDown()
    }
    // 右边
    func touchRight() {
        gameView.moveRight()
    }
    // 向上
    func touchUp() {
        gameView.rotate()
    }
    
    // MARK: 实现GameView代理方法
    func updateScore(score: Int) {
        
        self.scoreShow.text = "\(score)"
    }
    
    func updateSpeed(speed: Int) {
        
        self.speedShow.text = "\(speed)"
    }
    
    
    
    
}
