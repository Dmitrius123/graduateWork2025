//
//  ContentView.swift
//  NumbersFun
//
//  Created by Дмитрий Куприянов on 20.02.25.
//

import SwiftUI

struct ContentView: View {
    @State private var predictionResult: String = "Разпозната цифра: ?"
    @State private var drawView = DrawView()
    @State private var selectedDigit: Int = 0
    @State private var isTestMode = false
    @State private var showDrawingGuide = false
    @State private var animationProgress: CGFloat = 0.0
    let model = try? mnistCNN(configuration: .init())

    let levelColors: [UIColor] = [
        UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1),
        UIColor(red: 10/255, green: 0/255, blue: 50/255, alpha: 1),
        UIColor(red: 40/255, green: 0/255, blue: 40/255, alpha: 1),
        UIColor(red: 0/255, green: 50/255, blue: 0/255, alpha: 1),
        UIColor(red: 50/255, green: 0/255, blue: 0/255, alpha: 1),
        UIColor(red: 40/255, green: 40/255, blue: 0/255, alpha: 1),
        UIColor(red: 50/255, green: 0/255, blue: 50/255, alpha: 1),
        UIColor(red: 0/255, green: 0/255, blue: 50/255, alpha: 1),
        UIColor(red: 0/255, green: 50/255, blue: 50/255, alpha: 1),
        UIColor(red: 20/255, green: 0/255, blue: 20/255, alpha: 1)
    ]

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Начертай цифра: \(selectedDigit)")
                    .font(.title)
                    .padding(.top, geometry.size.height * 0.1)

                ZStack {
                    DrawViewRepresentable(drawView: $drawView, selectedDigit: selectedDigit)
                        .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9)
                        .background(Color(levelColors[selectedDigit]))
                        .cornerRadius(20)
                        .padding(.bottom, 20)

                    if showDrawingGuide {
                        AnimatedDigitView(digit: selectedDigit, progress: animationProgress)
                            .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9)
                            .cornerRadius(20)
                            .padding(.bottom, 20)// Без overlay
                    }
                }

                HStack {
                    Button("Изтрий") {
                        drawView.clear(backgroundColor: levelColors[selectedDigit])
                        predictionResult = "Разпозната цифра: ?"
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    Button("Провери") {
                        predictDigit()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.bottom, 10)

                Text(predictionResult)
                    .font(.headline)
                    .padding(.top, 20)
                    .padding(.bottom, 40)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(0..<10) { digit in
                            Button(action: {
                                selectedDigit = digit
                                drawView.clear(backgroundColor: levelColors[digit])
                                startAnimation()
                            }) {
                                Text("\(digit)")
                                    .font(.title)
                                    .frame(width: 50, height: 50)
                                    .background(Color(levelColors[digit]))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                }

                Spacer()

                Button("Тест") {
                    isTestMode = true
                }
                .padding()
                .frame(width: geometry.size.width * 0.5)
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.bottom, geometry.size.height * 0.07)
            }
            .padding(.bottom, geometry.size.height * 0.07)
            .frame(height: geometry.size.height)
            .fullScreenCover(isPresented: $isTestMode) {
                TestView()
            }
        }
    }

    func predictDigit() {
        guard let context = drawView.getViewContext(), let pixelBuffer = createPixelBuffer(from: context) else {
            return
        }

        let output = try? model?.prediction(image: pixelBuffer)
        let predictedDigit = output?.classLabel ?? "?"

        if let predictedInt = Int(predictedDigit), predictedInt == selectedDigit {
            predictionResult = "Браво! Това е \(predictedInt)"
        } else {
            predictionResult = "Опитай отново! Това е \(predictedDigit)"
        }
    }

    func createPixelBuffer(from context: CGContext) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        CVPixelBufferCreate(kCFAllocatorDefault, 28, 28, kCVPixelFormatType_OneComponent8, attrs, &pixelBuffer)

        guard let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        let ciContext = CIContext()
        let ciImage = CIImage(cgImage: context.makeImage()!)
        ciContext.render(ciImage, to: buffer)
        CVPixelBufferUnlockBaseAddress(buffer, [])

        return buffer
    }

    func startAnimation() {
        animationProgress = 0.0
        showDrawingGuide = true

        withAnimation(.easeInOut(duration: 2.5)) {
            animationProgress = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showDrawingGuide = false
        }
    }
}


struct AnimatedDigitView: View {
    let digit: Int
    let progress: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.opacity(0.7)
                    .frame(width: geometry.size.width, height: geometry.size.height)

                
                Path { path in
                    let w = geometry.size.width
                    let h = geometry.size.height
                    let strokeWidth: CGFloat = 12
                    
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
                    Color(red: 20/255, green: 0/255, blue: 40/255),
                    style: StrokeStyle(
                        lineWidth: 45,
                        lineCap: .round
                    )
                )
                .animation(.easeInOut(duration: 2), value: progress)
            }
        }
    }
}
