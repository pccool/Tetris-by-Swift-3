//
//  GameView.swift
//  Tetris
//
//  Created by 赵国欣 on 17/2/26.
//  Copyright © 2017年 coolFog. All rights reserved.
//

import UIKit
import AVFoundation



protocol GameViewDelegate {
    func updateScore(score: Int)
    func updateSpeed(speed: Int)
}




struct Block {
    
    var X: Int
    var Y: Int
    var Color: Int
    var description: String {
        
        return "Block[X=\(X),Y=\(Y),Color=\(Color)]"
    }
}

class GameView: UIView {
    
    var delegate: GameViewDelegate!
    
    let TETRIS_ROWS = 22
    let TETRIS_COLS = 15
    let CELL_SIZE: Int
    // 定义绘制网络的笔触的粗细
    let STROKE_WIDTH：Double = 1
    let GRID_OFFSET: Int
    
    let BASE_SPEED: Double = 0.6
    // 没方块是0
    let NO_BLOCK = 0
    // 记录当前积分
    var curScore: Int = 0
    // 记录当前速度
    var curSpeed = 1
    
    // 计时器
    var curTimer:Timer?
    
//2.0    var ctx: CGContextRef!
    var ctx: CGContext!
    // 定义一个 UIImage 实例，该实例代表内存中图片
    var image: UIImage!
    // 定义消除音乐的 AVAudioPlayer 对象
    var disPlayer: AVAudioPlayer!
    
    // 定义用于记录俄罗斯方块状态的二维数组的属性
    var tetris_status = [[Int]]()
    // 定义方块的颜色
    let colors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor,
                  #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor,
                  #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1).cgColor,
                  #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1).cgColor,
                  #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1).cgColor,
                  #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1).cgColor,
                  #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1).cgColor,
                  #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1).cgColor,
                  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor]
    
    // 定义几种可能出现的方块组合
    var blockArr = [[Block]]()
    //随机取出下落
    // 定义纪录 “正在下掉的四个方块” 位置
    var currentFall = [Block]()
    
    
    override init(frame: CGRect) {
        self.blockArr = [
            // 第一种可能出现的组合 Z
            [
                Block(X: TETRIS_COLS / 2 - 1, Y: 0, Color: 1),
                Block(X: TETRIS_COLS / 2, Y: 0, Color: 1),
                Block(X: TETRIS_COLS / 2, Y: 1, Color: 1),
                Block(X: TETRIS_COLS / 2 + 1, Y: 1, Color: 1)
            ],
            // 第二种可能出现的组合 反Z
            [
                Block(X: TETRIS_COLS / 2 + 1, Y: 0, Color: 2),
                Block(X: TETRIS_COLS / 2, Y: 0, Color: 2),
                Block(X: TETRIS_COLS / 2, Y: 1, Color: 2),
                Block(X: TETRIS_COLS / 2 - 1, Y: 1, Color: 2)
            ],
            // 第三种可能出现的组合 田
            [
                Block(X: TETRIS_COLS / 2 - 1, Y: 0, Color: 3),
                Block(X: TETRIS_COLS / 2, Y: 0, Color: 3),
                Block(X: TETRIS_COLS / 2 - 1, Y: 1, Color: 3),
                Block(X: TETRIS_COLS / 2 , Y: 1, Color: 3)
            ],
            // 第四种可能出现的组合 L
            [
                Block(X: TETRIS_COLS / 2 - 1, Y: 0, Color: 4),
                Block(X: TETRIS_COLS / 2 - 1, Y: 1, Color: 4),
                Block(X: TETRIS_COLS / 2 - 1, Y: 2, Color: 4),
                Block(X: TETRIS_COLS / 2 , Y: 2, Color: 4)
            ],
            // 第五种可能出现的组合 J
            [
                Block(X: TETRIS_COLS / 2, Y: 0, Color: 5),
                Block(X: TETRIS_COLS / 2, Y: 1, Color: 5),
                Block(X: TETRIS_COLS / 2, Y: 2, Color: 5),
                Block(X: TETRIS_COLS / 2 - 1, Y: 2, Color: 5)
            ],
            // 第六种可能出现的组合 ——
            [
                Block(X: TETRIS_COLS / 2, Y: 0, Color: 6),
                Block(X: TETRIS_COLS / 2, Y: 1, Color: 6),
                Block(X: TETRIS_COLS / 2, Y: 2, Color: 6),
                Block(X: TETRIS_COLS / 2, Y: 3, Color: 6)
            ],
            // 第七种可能出现的组合 土缺一
            [
                Block(X: TETRIS_COLS / 2, Y: 0, Color: 7),
                Block(X: TETRIS_COLS / 2 - 1, Y: 1, Color: 7),
                Block(X: TETRIS_COLS / 2, Y: 1, Color: 7),
                Block(X: TETRIS_COLS / 2 + 1, Y: 1, Color: 7)
            ],
            // 第8种可能出现的组合 飞机(士)
            [
                Block(X: TETRIS_COLS / 2, Y: 0, Color: 8),
                Block(X: TETRIS_COLS / 2 - 2, Y: 1, Color: 8),
                Block(X: TETRIS_COLS / 2 - 1, Y: 1, Color: 8),
                Block(X: TETRIS_COLS / 2, Y: 1, Color: 8),
                Block(X: TETRIS_COLS / 2 + 1, Y: 1, Color: 8),
                Block(X: TETRIS_COLS / 2 + 2, Y: 1, Color: 8),
                Block(X: TETRIS_COLS / 2, Y: 2, Color: 8),
                Block(X: TETRIS_COLS / 2 - 1, Y: 3, Color: 8),
                Block(X: TETRIS_COLS / 2, Y: 3, Color: 8),
                Block(X: TETRIS_COLS / 2 + 1, Y: 3, Color: 8)
            ]
        ]
        
        // 计算尔罗斯方块的大小
        self.CELL_SIZE = Int(frame.size.width) / TETRIS_COLS
        // 修正网格位置的偏移量
        self.GRID_OFFSET = (Int(frame.size.width) - CELL_SIZE * TETRIS_COLS) / 2
        super.init(frame: frame)
        // 获取消除方块音效的音频文件的 URL
        let disMusicURL = Bundle.main.url(forResource: "levelup", withExtension: "mp3")
        // 创建 AVAudioPlayer 对象
        disPlayer = try! AVAudioPlayer(contentsOf: disMusicURL!)
        disPlayer.numberOfLoops = 0
        // 开启内存中的绘图
        UIGraphicsBeginImageContext(self.bounds.size)
        // 获取 Quartz 2D 绘图的 CGContext 对象
        ctx = UIGraphicsGetCurrentContext()
        // 填充背景颜色
//2.0        CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGcolor)
        ctx.setFillColor(UIColor.white.cgColor)
//2.0        CGContextFillRect(ctx, self.bounds)
        ctx.fill(self.bounds)
        
        
        // 绘制尔罗斯方块的网络
        creatCells(rows: TETRIS_ROWS, cols: TETRIS_COLS, cellWidth: CELL_SIZE, cellHeight: CELL_SIZE)
        image = UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 定义一个创建绘制俄罗斯方块网格的方法
    func creatCells(rows: Int, cols: Int, cellWidth: Int, cellHeight: Int) {
        // 开始创建路径
        ctx.beginPath()
        // 绘制横向网络对应的路径
        for index in 0...TETRIS_ROWS {
//2.0            CGContextMoveToPoint(ctx, 0, CGFloat(index * CELL_SIZE))
//2.0            CGContextAddLineToPoint(ctx, CGFloat(TETRIS_COLS * CELL_SIZE), CGFloat(index * CELL_SIZE))
            ctx.move(to: CGPoint(x: GRID_OFFSET, y: (index * CELL_SIZE + GRID_OFFSET)))
            ctx.addLine(to: CGPoint(x: (TETRIS_COLS * CELL_SIZE + GRID_OFFSET), y: (index * CELL_SIZE + GRID_OFFSET)))
        }
        // 绘制竖向网络对应的路径
        for index in 0...TETRIS_COLS {
//2.0            CGContextMoveToPoint(ctx, CGFloat(index * CELL_SIZE), 0)
//2.0            CGContextAddLineToPoint(ctx, CGFloat(index * CELL_SIZE), CGFloat(TETRIS_COLS * CELL_SIZE))
            ctx.move(to: CGPoint(x: (index * CELL_SIZE + GRID_OFFSET), y: GRID_OFFSET))
            ctx.addLine(to: CGPoint(x: (index * CELL_SIZE + GRID_OFFSET), y: (TETRIS_ROWS * CELL_SIZE + GRID_OFFSET)))
        }
//2.0        CGContextClosePath(ctx)
        ctx.closePath()
        // 设置笔触颜色
//2.0        CGContextSetStrokeColorWithColor(ctx, UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).CGcolor)
//        ctx.setStrokeColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        ctx.setStrokeColor(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor)
        // 设置线条粗细
//2.0        CGContextSetLineWidth(ctx, CGFloat(STROKE_WIDTH))
        ctx.setLineWidth(CGFloat(STROKE_WIDTH：Double))
        
        // 绘制线条
//2.0        CGContextStrokePath(ctx)
        ctx.strokePath()
    }
    
//2.0    override func drawRect(rect: CGRect) {
//        // 获取绘图上下文
//2.0        UIGraphicsGetCurrentContext()
//        // 将内存中的 image 图片绘制在该组件的左上角
//2.0        image.drawAtPoint(CGPointZero)
//    }
    
    override func draw(_ rect: CGRect) {
        // 获取绘图上下文
        UIGraphicsGetCurrentContext()
        // 将内存中的 image 图片绘制在该组件的左上角
        image.draw(at: CGPoint.zero)
    }
    
    // 初始化游戏状态
    func initTetrisStatus() {
//2.0        let tmpRow = Array(count: TETRIS_COLS, repeatedValue: NO_BLOCK)
//2.0        tetris_status = Array(count: TETRIS_ROWS, repeatedValue: tempRow)
        let tmpRow = Array(repeating: NO_BLOCK, count: TETRIS_COLS)
        tetris_status = Array(repeating: tmpRow, count: TETRIS_ROWS)
    }
    
    
    /// 开始游戏
    func startGame() {
        // 将当前速度设为1
        self.curSpeed = 1
        self.delegate.updateSpeed(speed: self.curSpeed)
        // 将当前积分设为0
        self.curScore = 0
        self.delegate.updateScore(score: self.curScore)
        // 初始化游戏状态
        initTetrisStatus()
        // 初始化4个正在下落的方块
        initBlock()
        // 控制每隔固定时间执行一次向下"掉落"
        curTimer = Timer.scheduledTimer(timeInterval: BASE_SPEED / Double(curSpeed), target: self, selector: #selector(GameView.moveDown), userInfo: nil, repeats: true)
    }
    
    // 初始化"正在下掉"的方块组合
    func initBlock() {
        
        // 生成一个在 0 - blockArr.count  之间的随机数
        let rand =  Int(arc4random()) % blockArr.count
        // 随机取出 blockArr 数组中的某个元素为正在下掉的方块组合
        currentFall = blockArr[rand]
    }
    
    // 绘制俄罗斯方块的状态
    func drawBlock() {
        for i in 0..<TETRIS_ROWS {
            for j in 0..<TETRIS_COLS {
                // 有方块的地方绘制颜色
                if tetris_status[i][j] != NO_BLOCK {
                    // 设置填充颜色
                    // 绘制矩形
                    setColorAndRect(context: ctx, color: colors[tetris_status[i][j]], X: j, Y: i)
                }
                    // 没有方块的地方绘制白色
                else {
                    // 设置填充颜色
                    // 绘制矩形
                    setColorAndRect(context: ctx, color: UIColor.white.cgColor, X: j, Y: i)
                }
            }
        }
    }
    
    // 控制方块组合向下掉落
    func moveDown() {
        // 定义能否向下掉落的旗标
        var canDown = true
        for i in 0..<currentFall.count {
            // 判断是否已经到了"最底下"
            if currentFall[i].Y >= TETRIS_ROWS - 1 {
                canDown = false
                break
            }
            
            // 判断下一格是否"有方块",如果下一格有方块,不能向下掉落
            if tetris_status[currentFall[i].Y + 1][currentFall[i].X] != NO_BLOCK {
                canDown = false
                break
            }
        }
        
        // 如果能"向下掉落"
        if canDown {
            self.drawBlock()
            // 将下移前的每个方块的背景色涂成白色
            for i in 0..<currentFall.count {
                let cur = currentFall[i]
                // 设置填充颜色
                // 绘制矩形
                setColorAndRect(context: ctx, color: UIColor.white.cgColor, X: cur.X, Y: cur.Y)
            }
            // 遍历每个方块,控制每个方块的y坐标加1
            // 也就是控制方块都掉落一格
            for i in 0..<currentFall.count {
                currentFall[i].Y += 1
            }
            // 将下移后的每个方块的背景涂成该方块的颜色
            for i in 0 ..< currentFall.count {
                let cur = currentFall[i]
                // 设置填充颜色
                // 绘制矩形
                setColorAndRect(context: ctx, color: colors[cur.Color], X: cur.X, Y: cur.Y)
            }
        }
            // 不能向下掉落
        else {
            // 遍历每个方块,把每个方块的值记录到tetris_status数组中
            for i in 0..<currentFall.count {
                let cur = currentFall[i]
                // 如果有方块已经到最上面了,表明输了
                if cur.Y < 2 {
                    // 清除计时器
                    curTimer?.invalidate()
                    // 创建提示框
                    let alert = UIAlertController(title: "游戏结束", message: "游戏已结束，请问是否重新开始？", preferredStyle: .alert)
                    // 为提示框设置按钮,并设置当该按钮被点击时,重启游戏
                    let defaultAction = UIAlertAction(title: "是", style: .default, handler: { (action) in
                        self.startGame()
                    })
                    
                    alert.addAction(defaultAction)
                    // 获取该UI控件所在的视图控制器
//                    let nextResponder = self.superview?.nextResponder() as! UIViewController
                    let nextResponder = self.superview?.next as! UIViewController
                    // 显示提示框
                    nextResponder.present(alert, animated: true, completion: nil)
                    return				
                }
                // 把每个方块当前所在位置赋为当前方块的颜色值
                tetris_status[cur.Y][cur.X] = cur.Color
            }
            // 判断是否有可"消除"的行
            lineFull()
            // 开始一组新的方块
            initBlock()			
        }
        
        // 获取缓冲区的图片
        image = UIGraphicsGetImageFromCurrentImageContext()
        // 通知该组件重绘
        self.setNeedsDisplay()		
    }
    
    // 判断是否有一行已满
    func lineFull() {
        // 依次遍历每一行
        for i in 0..<TETRIS_ROWS {
            var flag = true
            // 遍历当前行的每个单元格
            for j in 0..<TETRIS_COLS {
                if tetris_status[i][j] == NO_BLOCK {
                    flag = false
                    break
                }
            }
            // 如果当前行已经全部有方块了
            if flag {
                // 将当前积分增加100
                curScore += 100
                self.delegate.updateScore(score: curScore)
                // 如果当前积分达到升级界限
                if curScore >= curSpeed * curSpeed * 500 {
                    // 速度增加1
                    curSpeed += 1
                    self.delegate.updateSpeed(speed: curSpeed)
                    // 让原有计时器失效,重新开启新的计时器
                    curTimer?.invalidate()
                    curTimer = Timer.scheduledTimer(timeInterval: BASE_SPEED / Double(curSpeed), target: self, selector: #selector(GameView.moveDown), userInfo: nil, repeats: true)
                }
                // 把当前行的所有方块下移一行
                /*
                 for i in (0...10).reversed() {}
                 */
                // for var j = i; j > 0; j--
                for j in ((0 + 1)...i).reversed() {
                    for k in 0..<TETRIS_COLS {
                        tetris_status[j][k] = tetris_status[j - 1][k]
                    }
                }
                // 播放取消方块的音乐
                if !disPlayer.isPlaying {
                    disPlayer.play()
                }
            }
        }		
    }
    
    //MARK: 定义左边移动的方法
    func moveLeft() {
        // 定义左边移动的标签
        var canLeft = true
        for i in 0..<currentFall.count {
            // 如果已经到了最左边,不能左移
            if currentFall[i].X <= 0 {
                canLeft = false
                break
            }
            // 或左边位置已有方块,不能左移
            if tetris_status[currentFall[i].Y][currentFall[i].X - 1] != NO_BLOCK {
                canLeft = false
                break
            }
        }
        // 如果可以左移
        if canLeft {
            self.drawBlock()
            // 将左移前的每一个方块背景涂成白色
            for i in 0..<currentFall.count {
                let cur = currentFall[i]
                // 设置填充颜色
                // 绘制矩形
                setColorAndRect(context: ctx, color: UIColor.white.cgColor, X: cur.X, Y: cur.Y)
            }
            
            // 左移所有正在掉落的方块
            for i in 0..<currentFall.count {
                currentFall[i].X -= 1
            }
            
            // 将左移后的每一个方块的背景涂成方块对应的颜色
            for i in 0..<currentFall.count {
                let  cur = currentFall[i]
                // 设置填充颜色
                // 绘制矩形
                setColorAndRect(context: ctx, color: colors[cur.Color], X: cur.X, Y: cur.Y)
            }
            // 获取缓冲区的图片
            image = UIGraphicsGetImageFromCurrentImageContext()
            // 通知重新绘制
            self.setNeedsDisplay()
            
        }
    }
    
    // MARK: 定义右边移动的方法
    func moveRight() {
        // 能否右移动的标签
        var canRight = true
        for i in 0..<currentFall.count {
            
            // 如果已经到最右边,不能右移
            if currentFall[i].X >= TETRIS_COLS - 1 {
                canRight = false
                break
            }
            // 如果右边位置已有方块，不能右移
            if tetris_status[currentFall[i].Y][currentFall[i].X + 1] != NO_BLOCK {
                canRight = false
                break
            }
        }
        // 如果能右移
        if canRight {
            
            self.drawBlock()
            // 将右移前的每一个方块背景涂成白色
            for i in 0..<currentFall.count {
                let cur = currentFall[i]
                // 设置填充颜色
                // 绘制矩形
                setColorAndRect(context: ctx, color: UIColor.white.cgColor, X: cur.X, Y: cur.Y)
            }
            
            // 右移所有正在掉落的方块
            for i in 0..<currentFall.count {
                currentFall[i].X += 1
            }
            
            // 将右移后的每一个方块的背景涂成方块对应的颜色
            for i in 0..<currentFall.count {
                let  cur = currentFall[i]
                // 设置填充颜色
                // 绘制矩形
                setColorAndRect(context: ctx, color: colors[cur.Color], X: cur.X, Y: cur.Y)
            }
            // 获取缓冲区的图片
            image = UIGraphicsGetImageFromCurrentImageContext()
            // 通知重新绘制
            self.setNeedsDisplay()
        }
    }
    
    // MARK: 定义旋转的方法
    func rotate() {
        // 定义是否能旋转的标签
        var canRotate = true
        for i in 0..<currentFall.count {
            let preX = currentFall[i].X
            let preY = currentFall[i].Y
            // 始终以第三块作为旋转的中心
            // 当 i == 2的时候，说明是旋转的中心
            if i != 2 {
                // 计算方块旋转后的x，y坐标
                let afterRotateX  =  currentFall[2].X + preY - currentFall[2].Y
                let afterRotateY  =  currentFall[2].Y + currentFall[2].X - preX
                
                // 如果旋转后的x,y坐标越界，或者旋转后的位置已有别的方块，表示不能旋转
                if afterRotateX < 0 || afterRotateX > TETRIS_COLS - 1 || afterRotateY < 0 || afterRotateY > TETRIS_ROWS - 1 || tetris_status[afterRotateY][afterRotateX] != NO_BLOCK {
                    canRotate = false
                    break
                }
            }
        }
        // 如果能旋转
        if canRotate {
            self.drawBlock()
            for i in 0..<currentFall.count {
                let cur = currentFall[i]
                // 设置填充颜色
                // 绘制矩形
                setColorAndRect(context: ctx, color: UIColor.white.cgColor, X: cur.X, Y: cur.Y)
            }
            for i in 0..<currentFall.count {
                let preX = currentFall[i].X
                let preY = currentFall[i].Y
                // 始终以第三个方块作为旋转中心
                if i != 2 {
                    currentFall[i].X = currentFall[2].X + preY - currentFall[2].Y
                    currentFall[i].Y = currentFall[2].Y + currentFall[2].X - preX
                }
            }
            for i in 0..<currentFall.count {
                let cur = currentFall[i]
                // 设置填充颜色
                // 绘制矩形
                setColorAndRect(context: ctx, color: colors[cur.Color], X: cur.X, Y: cur.Y)
            }
            // 获取缓存区的图片
            image = UIGraphicsGetImageFromCurrentImageContext()
            // 通知重新绘制
            self.setNeedsDisplay()
        }        
    }
    
    func setColorAndRect(context: CGContext, color: CGColor, X: Int, Y: Int) {
        // 设置填充颜色
        context.setFillColor(color)
        // 绘制矩形
        context.fill(CGRect(x: CGFloat(X * CELL_SIZE + STROKE_WIDTH：Double + GRID_OFFSET),
                        y: CGFloat(Y * CELL_SIZE + STROKE_WIDTH：Double + GRID_OFFSET),
                        width: CGFloat(CELL_SIZE - STROKE_WIDTH：Double * 2),
                        height: CGFloat(CELL_SIZE - STROKE_WIDTH：Double * 2)))
    }
    
    
    
    
}
