//
//  DrawView.swift
//  NumbersFun
//
//  Created by Дмитрий Куприянов on 20.02.25.
//

import CoreML
import UIKit
import AVFoundation

class DrawView: UIView {
    var linewidth = CGFloat(40) { didSet { setNeedsDisplay() } }
    var color = UIColor.white { didSet { setNeedsDisplay() } }
    
    var lines: [Line] = [] {
        didSet { setNeedsDisplay() }
    }
    var lastPoint: CGPoint!
    var audioPlayer: AVAudioPlayer?
    var onUserDraw: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAudio()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAudio()
    }
    
    private func setupAudio() {
        guard let url = Bundle.main.url(forResource: "pencil_sound", withExtension: "mp3") else { return }
        
        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.numberOfLoops = -1
        audioPlayer?.prepareToPlay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastPoint = touches.first!.location(in: self)
        audioPlayer?.play()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let newPoint = touches.first!.location(in: self)
        lines.append(Line(start: lastPoint, end: newPoint))
        lastPoint = newPoint
        setNeedsDisplay()
        onUserDraw?()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        audioPlayer?.pause()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let drawPath = UIBezierPath()
        drawPath.lineCapStyle = .round
        
        for line in lines {
            drawPath.move(to: line.start)
            drawPath.addLine(to: line.end)
        }
        
        drawPath.lineWidth = linewidth
        color.set()
        drawPath.stroke()
    }
    
    func clear(backgroundColor: UIColor) {
        lines.removeAll()
        setNeedsDisplay()
        self.layer.sublayers?.removeAll()
        self.backgroundColor = backgroundColor
    }
    
    func getViewContext() -> CGContext? {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGImageAlphaInfo.none.rawValue
        let context = CGContext(data: nil, width: 28, height: 28, bitsPerComponent: 8, bytesPerRow: 28, space: colorSpace, bitmapInfo: bitmapInfo)
        
        context?.translateBy(x: 0, y: 28)
        context?.scaleBy(x: 28 / self.frame.size.width, y: -28 / self.frame.size.height)
        
        self.layer.render(in: context!)
        
        return context
    }
}

class Line {
    var start, end: CGPoint
    
    init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
    }
}
