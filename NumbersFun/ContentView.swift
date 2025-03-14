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
    @State private var isAnimating = false
    @State private var failedAttempts = 0
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
                            .opacity(showDrawingGuide ? 1 : 0)
                            .animation(.easeInOut(duration: 0.3), value: showDrawingGuide)
                            .cornerRadius(20)
                            .padding(.bottom, 20)
                    }
                }

                HStack {
                    Button("Изтрий") {
                        drawView.clear(backgroundColor: levelColors[selectedDigit])
                        predictionResult = "Разпозната цифра: ?"
                    }
                    .padding()
                    .background(Color(red: 139/255, green: 0, blue: 0))
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    Button("Провери") {
                        predictDigit()
                    }
                    .padding()
                    .background(Color(red: 0/255, green: 100/255, blue: 0/255))
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
                .background(Color(red: 75/255, green: 0/255, blue: 130/255))
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
            failedAttempts = 0
        } else {
            predictionResult = "Опитай отново! Това е \(predictedDigit)"
            failedAttempts += 1

            if failedAttempts == 3 {
                failedAttempts = 0
                startAnimation()
            }
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
        failedAttempts = 0
        
        withAnimation(nil) {
            animationProgress = 0.0
            showDrawingGuide = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            showDrawingGuide = true

            withAnimation(.easeInOut(duration: 2.5)) {
                animationProgress = 1.0
            }
        }
    }
}


