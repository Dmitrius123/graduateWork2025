//
//  ContentView.swift
//  NumbersFun
//
//  Created by Дмитрий Куприянов on 20.02.25.
//

import CoreML
import SwiftUI



struct ContentView: View {
    @Environment(\.colorScheme)  var colorScheme
    @State private var predictionResult: String = NSLocalizedString("digit", comment: "")
    @State private var predictionTextColor: Color = .primary
    @State private var selectedLanguage: String = Locale.current.language.languageCode?.identifier ?? "bg"
    @State private var drawView = DrawView()
    @State private var selectedDigit: Int = 0
    @State private var isTestMode = false
    @State private var showDrawingGuide = false
    @State private var animationProgress: CGFloat = 0.0
    @State private var failedAttempts = 0
    @State private var hintsEnabled = true
    @State private var showAlert = false
    let model = try? MLNumbers(configuration: .init())

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
                    ZStack {
                        DrawViewRepresentable(drawView: $drawView, selectedDigit: selectedDigit)
                            .background(Color(levelColors[selectedDigit]))
                            .cornerRadius(20)
                            .padding(.horizontal, geometry.size.height * 0.02)
                            .padding(.vertical, geometry.size.height * 0.005)
                            .padding(.top, 20)
                            .frame(width: geometry.size.width * 1, height: geometry.size.width * 1)
                        
                        if showDrawingGuide && hintsEnabled {
                            AnimatedDigitView(digit: selectedDigit, progress: animationProgress)
                                .animation(.easeInOut(duration: 0.3), value: showDrawingGuide)
                                .cornerRadius(20)
                                .padding(.horizontal, geometry.size.height * 0.02)
                                .padding(.vertical, geometry.size.height * 0.005)
                                .padding(.top, 20)
                        }
                    }
                    
                    
                    Text(predictionResult)
                        .font(.custom("Marker Felt", size: 33))
                        .padding(.vertical, geometry.size.height * 0.035)
                        .foregroundColor(predictionTextColor)

                    HStack(spacing: 25) {
                        Button("Изтрий") {
                            drawView.clear(backgroundColor: levelColors[selectedDigit])
                            predictionResult = NSLocalizedString("digit", comment: "")
                            predictionTextColor = .primary
                        }
                        .modifier(CustomButtonStyle(backgroundColor: Color(red: 139/255, green: 0, blue: 0)))
                        
                        Button("Провери") {
                            predictDigit()
                        }
                        .modifier(CustomButtonStyle(backgroundColor: Color(red: 0/255, green: 100/255, blue: 0/255)))
                    }
                    .padding(.bottom, geometry.size.height * 0.05)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(0..<10) { digit in
                                Button(action: {
                                    selectedDigit = digit
                                    drawView.clear(backgroundColor: levelColors[digit])
                                    predictionResult = NSLocalizedString("digit", comment: "")
                                    predictionTextColor = .primary
                                    if hintsEnabled {
                                        startAnimation()
                                    }
                                }) {
                                    Text("\(digit)")
                                        .font(.custom("Marker Felt", size: 45))
                                        .frame(width: 70, height: 70)
                                        .background(Color(levelColors[digit]))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.02)
                        .padding(.bottom, geometry.size.height * 0.01)
                    }


                    Button("Тест") {
                        isTestMode = true
                    }
                    .font(.custom("Marker Felt", size: 45))
                    .padding()
                    .frame(width: geometry.size.width * 0.5, height: 70)
                    .background(Color(red: 75/255, green: 0/255, blue: 130/255))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, geometry.size.height * 0.1)
           
                }
                .fullScreenCover(isPresented: $isTestMode) {
                    TestView()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {showAlert = true}) {
                            Image(systemName: "globe")
                                .font(.title3)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            hintsEnabled.toggle()
                        }) {
                            Image(systemName: hintsEnabled ? "lightbulb.fill" : "lightbulb.slash.fill")
                                .font(.title3)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Начертай цифра: \(selectedDigit)")
                            .font(.custom("Marker Felt", size: 35))
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Рестартиране"),
                        message: Text("Приложението ще се затвори сега. Моля, отворете го отново."),
                        
                        dismissButton: .default(Text("OK")){
                            toggleLanguage()
                        }
                    )
                }
            }
        }
    }

    func predictDigit() {
        guard let context = drawView.getViewContext(), let pixelBuffer = createPixelBuffer(from: context) else { return }

        let output = try? model?.prediction(image: pixelBuffer)
        let predictedDigit = output?.classLabel ?? "?"

        if let predictedInt = Int(predictedDigit), predictedInt == selectedDigit {
            predictionResult = String(format: NSLocalizedString("true", comment: ""), predictedInt)
            predictionTextColor = Color(red: 0/255, green: 100/255, blue: 0/255)

            failedAttempts = 0
        } else {
            predictionResult = NSLocalizedString("false", comment: "") + " \(predictedDigit)"
            predictionTextColor = Color(red: 139/255, green: 0, blue: 0)
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

struct CustomButtonStyle: ViewModifier {
    let backgroundColor: Color

    func body(content: Content) -> some View {
        content
            .font(.custom("Marker Felt", size: 30))
            .frame(width: 130, height: 50)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

#Preview {
    ContentView()
}
