//
//  ContentView.swift
//  NumbersFun
//
//  Created by Дмитрий Куприянов on 20.02.25.
//

import SwiftUI

struct ContentView: View {
    @State private var predictionResult: String = NSLocalizedString("digit", comment: "")
    @State private var selectedLanguage: String = Locale.current.language.languageCode?.identifier ?? "bg"
    @State private var drawView = DrawView()
    @State private var selectedDigit: Int = 0
    @State private var isTestMode = false
    @State private var showDrawingGuide = false
    @State private var animationProgress: CGFloat = 0.0
    @State private var isAnimating = false
    @State private var failedAttempts = 0
    @State private var hintsEnabled = true
    @State private var showAlert = false
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
            NavigationView {
                VStack {
                    Text("Начертай цифра: \(selectedDigit)")
                        .font(.title)
                        .padding(.top, 30)
                        .padding()

                    ZStack {
                        DrawViewRepresentable(drawView: $drawView, selectedDigit: selectedDigit)
                            .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9)
                            .background(Color(levelColors[selectedDigit]))
                            .cornerRadius(20)
                            .padding(.bottom, 20)

                        if showDrawingGuide && hintsEnabled {
                            AnimatedDigitView(digit: selectedDigit, progress: animationProgress)
                                .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9)
                                .opacity(1)
                                .animation(.easeInOut(duration: 0.3), value: showDrawingGuide)
                                .cornerRadius(20)
                                .padding(.bottom, 20)
                        }
                    }

                    HStack {
                        Button("Изтрий") {
                            drawView.clear(backgroundColor: levelColors[selectedDigit])
                            predictionResult = NSLocalizedString("digit", comment: "")
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
                                    if hintsEnabled {
                                        startAnimation()
                                    }
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {showAlert = true}) {
                            Image(systemName: "globe")
                                .font(.title2)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            hintsEnabled.toggle()
                        }) {
                            Image(systemName: hintsEnabled ? "lightbulb.fill" : "lightbulb.slash.fill")
                                .font(.title2)
                        }
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Рестартиране"),
                        message: Text("Приложението ще се затвори сега. Моля, отворете го отново."),
                        dismissButton: .default(Text("OK")) {
                            toggleLanguage()
                        }
                    )
                }
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
            predictionResult = String(format: NSLocalizedString("true", comment: ""), predictedInt)
            failedAttempts = 0
        } else {
            predictionResult = NSLocalizedString("false", comment: "") + " \(predictedDigit)"
            failedAttempts += 1

            if failedAttempts == 3 && hintsEnabled {
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
        guard hintsEnabled else { return }

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

    func toggleLanguage() {
        selectedLanguage = (selectedLanguage == "en") ? "bg" : "en"
        UserDefaults.standard.setValue([selectedLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        exit(0)
    }
}
