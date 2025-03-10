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
                        path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.2))
                        path.move(to: CGPoint(x: w * 0.5, y: h * 0.2))
                        path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.8))
                        
                    case 2:
                        path.move(to: CGPoint(x: w * 0.3, y: h * 0.2))
                        path.addArc(tangent1End: CGPoint(x: w * 0.7, y: h * 0.2), tangent2End: CGPoint(x: w * 0.7, y: h * 0.8), radius: w * 0.2)
                        path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.8))
                        path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.8))
                    case 3:
                        path.move(to: CGPoint(x: w * 0.4, y: h * 0.2))
                        path.addArc(tangent1End: CGPoint(x: w * 0.7, y: h * 0.2), tangent2End: CGPoint(x: w * 0.7, y: h * 0.5), radius: w * 0.2)
                        
                        path.addArc(tangent1End: CGPoint(x: w * 0.7, y: h * 0.5), tangent2End: CGPoint(x: w * 0.4, y: h * 0.7), radius: w * 0.2)
                        
                        path.move(to: CGPoint(x: w * 0.3, y: h-h * 0.1))
                        path.addArc(tangent1End: CGPoint(x: w * 0.7, y: h - h * 0.1), tangent2End: CGPoint(x: w * 0.7, y: h - h * 0.4), radius: w * 0.2)
                        path.addArc(tangent1End: CGPoint(x: w * 0.7, y: h - h * 0.4), tangent2End: CGPoint(x: w * 0.4, y: h - h * 0.6), radius: w * 0.2)
                    case 4:
                        path.move(to: CGPoint(x: w * 0.7, y: h * 0.8))
                        path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.2))
                        path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.6))
                        path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.6))
                    case 5:
                        path.move(to: CGPoint(x: w * 0.7, y: h * 0.2))
                        path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.2))
                        path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.4))
                        path.addArc(tangent1End: CGPoint(x: w * 0.7, y: h * 0.4), tangent2End: CGPoint(x: w * 0.7, y: h * 0.7), radius: w * 0.2)
                        
                        path.addArc(tangent1End: CGPoint(x: w * 0.7, y: h * 0.7), tangent2End: CGPoint(x: w * 0.3, y: h * 1), radius: w * 0.2)
                        path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.76))
                    case 6:
                        path.move(to: CGPoint(x: w - w * 0.4, y: h * 0.2))
                        path.addArc(tangent1End: CGPoint(x: w - w * 0.7, y: h * 0.2), tangent2End: CGPoint(x: w - w * 0.7, y: h * 0.5), radius: w * 0.2)

                        path.addArc(tangent1End: CGPoint(x: w - w * 0.7, y: h * 0.8), tangent2End: CGPoint(x: w - w * 0.3, y: h * 0.8), radius: w * 0.2)

                        path.addEllipse(in: CGRect(
                            x: geometry.size.width * 0.31,
                            y: geometry.size.height * 0.45,
                            width: geometry.size.width * 0.35,
                            height: geometry.size.height * 0.35
                        ))
                    case 7:
                        path.move(to: CGPoint(x: w * 0.3, y: h * 0.2))
                        path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.2))
                        path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.8))
                    case 8:
                        let centerX = w * 0.5
                        let centerY = h * 0.5
                        let radiusSmall = w * 0.15
                        let radiusLarge = w * 0.20
                        path.move(to: CGPoint(x: centerX, y: centerY))
                        path.addArc(center: CGPoint(x: centerX, y: centerY - radiusLarge),
                                    radius: radiusSmall,
                                    startAngle: .degrees(90),
                                    endAngle: .degrees(450),
                                    clockwise: false)

                        path.move(to: CGPoint(x: centerX, y: centerY))
                        path.addArc(center: CGPoint(x: centerX, y: centerY + radiusLarge),
                                    radius: radiusLarge,
                                    startAngle: .degrees(-90),
                                    endAngle: .degrees(270),
                                    clockwise: true)
                    case 9:
                        path.move(to: CGPoint(x: w * 0.3, y: h * 0.2))
                        path.addArc(tangent1End: CGPoint(x: w * 0.7, y: h * 0.2), tangent2End: CGPoint(x: w * 0.7, y: h * 0.8), radius: w * 0.2)
                        path.addArc(tangent1End: CGPoint(x: w * 0.3, y: h * 0.8), tangent2End: CGPoint(x: w * 0.3, y: h * 0.5), radius: w * 0.2)
                        path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.5))
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
