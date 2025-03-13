//
//  AnimatedDigitView.swift
//  NumbersFun
//
//  Created by Дмитрий Куприянов on 11.03.25.
//

import SwiftUI

struct AnimatedDigitView: View {
    let digit: Int
    let progress: CGFloat
    @State private var isDigitVisible = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.opacity(isDigitVisible ? 0.7 : 0)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                if isDigitVisible {
                    Path { path in
                        let w = geometry.size.width
                        let h = geometry.size.height
                        
                        switch digit {
                        case 0:
                            path.addEllipse(in: CGRect(
                                x: geometry.size.width * 0.25,
                                y: geometry.size.height * 0.15,
                                width: geometry.size.width * 0.5,
                                height: geometry.size.height * 0.7
                            ))
                        case 1:
                            path.move(to: CGPoint(x: w * 0.35, y: h * 0.4))
                            path.addLine(to: CGPoint(x: w * 0.55, y: h * 0.15))
                            path.move(to: CGPoint(x: w * 0.55, y: h * 0.15))
                            path.addLine(to: CGPoint(x: w * 0.55, y: h * 0.85))
                            
                        case 2:
                            let centerX = w * 0.5
                            let centerY = h * 0.6
                            let radiusSmall = w * 0.2
                            let radiusLarge = w * 0.25
                            
                            path.addArc(center: CGPoint(x: centerX, y: centerY - radiusLarge),
                                        radius: radiusSmall,
                                        startAngle: .degrees(-180),
                                        endAngle: .degrees(43.73),
                                        clockwise: false)
                            path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.85))
                            path.move(to: CGPoint(x: w * 0.3, y: h * 0.85))
                            path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.85))
                            
                        case 3:
                            let centerX = w * 0.5
                            let centerY = h * 0.5
                            let radiusSmall = w * 0.15
                            let radiusLarge = w * 0.2
                            
                            path.addArc(center: CGPoint(x: centerX, y: centerY - radiusLarge),
                                        radius: radiusSmall,
                                        startAngle: .degrees(-140),
                                        endAngle: .degrees(90),
                                        clockwise: false)
                            
                            path.move(to: CGPoint(x: w * 0.49, y: h * 0.452))
                            path.addArc(center: CGPoint(x: centerX, y: centerY + radiusLarge - 17.5),
                                        radius: radiusLarge,
                                        startAngle: .degrees(-90),
                                        endAngle: .degrees(140),
                                        clockwise: false)
                        case 4:
                            
                            path.move(to: CGPoint(x: w * 0.75, y: h * 0.7))
                            path.addLine(to: CGPoint(x: w * 0.25, y: h * 0.7))
                            path.move(to: CGPoint(x: w * 0.25, y: h * 0.7))
                            path.addLine(to: CGPoint(x: w * 0.65, y: h * 0.15))
                            path.move(to: CGPoint(x: w * 0.65, y: h * 0.15))
                            path.addLine(to: CGPoint(x: w * 0.65, y: h * 0.85))
                        case 5:
                            path.move(to: CGPoint(x: w * 0.7, y: h * 0.15))
                            path.addLine(to: CGPoint(x: w * 0.31, y: h * 0.15))
                            path.move(to: CGPoint(x: w * 0.31, y: h * 0.15))
                            path.addLine(to: CGPoint(x: w * 0.31, y: h * 0.42))
                            path.move(to: CGPoint(x: w * 0.31, y: h * 0.43))
                            
                            let centerX = w * 0.5
                            let centerY = h * 0.6
                            let radiusLarge = w * 0.25
                            
                            path.addArc(center: CGPoint(x: centerX, y: centerY),
                                        radius: radiusLarge,
                                        startAngle: .degrees(-130),
                                        endAngle: .degrees(150),
                                        clockwise: false)
                        case 6:
                            
                            path.move(to: CGPoint(x: w * 0.7, y: h * 0.15))
                            path.addArc(tangent1End: CGPoint(x: w * 0.215, y: h * -0.165),
                                        tangent2End: CGPoint(x: w * 0.35, y: h * 1.0),
                                        radius: w * 0.27
                            )
                            
                            
                            let centerX = geometry.size.width * 0.52
                            let centerY = geometry.size.height * 0.62
                            let radius = geometry.size.width * 0.23
                            
                            path.addArc(center: CGPoint(x: centerX, y: centerY),
                                        radius: radius,
                                        startAngle: .degrees(-180),
                                        endAngle: .degrees(180),
                                        clockwise: true)
                            
                        case 7:
                            path.move(to: CGPoint(x: w * 0.3, y: h * 0.15))
                            path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.15))
                            path.move(to: CGPoint(x: w * 0.7, y: h * 0.15))
                            path.addLine(to: CGPoint(x: w * 0.4, y: h * 0.85))
                        case 8:
                            let centerX = w * 0.5
                            let centerY = h * 0.5
                            let radiusSmall = w * 0.15
                            let radiusLarge = w * 0.2
                            
                            path.addArc(center: CGPoint(x: centerX, y: centerY - radiusLarge),
                                        radius: radiusSmall,
                                        startAngle: .degrees(90),
                                        endAngle: .degrees(450),
                                        clockwise: false)
                            
                            path.addArc(center: CGPoint(x: centerX, y: centerY + radiusLarge - 18.2),
                                        radius: radiusLarge,
                                        startAngle: .degrees(-90),
                                        endAngle: .degrees(270),
                                        clockwise: true)
                        case 9:
                            
                            
                            let centerX = geometry.size.width * 0.48
                            let centerY = geometry.size.height * 0.38
                            let radius = geometry.size.width * 0.23
                            
                            path.addArc(center: CGPoint(x: centerX, y: centerY),
                                        radius: radius,
                                        startAngle: .degrees(0),
                                        endAngle: .degrees(360),
                                        clockwise: true)
                            
                            
                            path.move(to: CGPoint(x: w * 0.71, y: h * 0.38))
                            path.addArc(tangent1End: CGPoint(x: w * 0.71, y: h * 1.165),
                                        tangent2End: CGPoint(x: w * 0.35, y: h * 0.88),
                                        radius: w * 0.27
                            )
                            
                            
                        default:
                            break
                        }
                    }
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.black,
                        style: StrokeStyle(
                            lineWidth: 45,
                            lineCap: .round
                        )
                    )
                    .animation(.easeInOut(duration: 2.5), value: progress)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
                    withAnimation {
                        isDigitVisible = false
                    }
                }
            }
            .opacity(isDigitVisible ? 1 : 0)
        }
    }
}
