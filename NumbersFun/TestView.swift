//
//  TestView.swift
//  NumbersFun
//
//  Created by Дмитрий Куприянов on 7.03.25.
//

import CoreML
import SwiftUI

struct TestView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var drawView = DrawView()
    @State private var testDigits: [Int] = (0..<10).map { _ in Int.random(in: 0...9) }
    @State private var currentLevel = 1
    @State private var totalLevels = 10
    @State private var currentIndex = 0
    @State private var correctAnswers = 0
    @State private var showResult = false
    @State private var isErasePressed = false
    @State private var isCheckPressed = false
    
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
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    ZStack {
                        Text("Начертай цифра: \(testDigits[currentIndex])")
                            .font(.custom("Marker Felt", size: 35))
                            .multilineTextAlignment(.center)
                            .padding(.top, geometry.size.height * 0.1)
                            .rotation3DEffect(
                                .degrees(Double(currentIndex % 2 == 0 ? 360 : 0)),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .animation(.easeInOut(duration: 0.4), value: currentIndex)
                    }
                    DrawViewRepresentable(drawView: $drawView, selectedDigit: testDigits[currentIndex])
                        .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9)
                        .background(Color(levelColors[testDigits[currentIndex]]))
                        .cornerRadius(20)
                        .padding(.bottom, 20)
                        .padding(.vertical, geometry.size.height * 0.04)
                    
                    HStack(spacing: 25) {
                        Button("Изтрий") {
                            isErasePressed = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                isErasePressed = false
                            }
                            drawView.clear(backgroundColor: levelColors[testDigits[currentIndex]])
                        }
                        .font(.custom("Marker Felt", size: 30))
                        .frame(width: 130, height: 50)
                        .background(Color(red: 139/255, green: 0, blue: 0))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .scaleEffect(isErasePressed ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isErasePressed)
                        
                        Button("Провери") {
                            isCheckPressed = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                isCheckPressed = false
                            }
                            checkAnswer()
                        }
                        .font(.custom("Marker Felt", size: 30))
                        .frame(width: 130, height: 50)
                        .background(Color(red: 0/255, green: 100/255, blue: 0/255))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .scaleEffect(isCheckPressed ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isCheckPressed)
                    }
                    
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 20)
                .alert(isPresented: $showResult) {
                    Alert(
                        title: Text("Резултат"),
                        message: Text("Правилни отговори: \(correctAnswers) от 10"),
                        dismissButton: .default(Text("Затвори")) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("X")
                            .font(.custom("Marker Felt", size: 40))
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("\(currentLevel)/\(totalLevels)")
                        .font(.custom("Marker Felt", size: 40))
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    func checkAnswer() {
        guard let context = drawView.getViewContext(), let pixelBuffer = createPixelBuffer(from: context) else {
            return
        }
        
        guard let model = try? MLNumbers(configuration: .init()) else { return }
        let output = try? model.prediction(image: pixelBuffer)
        let predictedDigit = output?.classLabel ?? "?"
        
        if let predictedInt = Int(predictedDigit), predictedInt == testDigits[currentIndex] {
            correctAnswers += 1
        }
        
        if currentIndex < 9 {
            withAnimation(.easeInOut(duration: 0.4)) {
                currentIndex += 1
                currentLevel += 1
            }
            drawView.clear(backgroundColor: levelColors[testDigits[currentIndex]])
        } else {
            showResult = true
        }
    }
    
    func createPixelBuffer(from context: CGContext) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, 28, 28, kCVPixelFormatType_OneComponent8, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let ciContext = CIContext()
        guard let cgImage = context.makeImage() else {
            return nil
        }
        let ciImage = CIImage(cgImage: cgImage)
        ciContext.render(ciImage, to: buffer)
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
}

#Preview {
    TestView()
}
