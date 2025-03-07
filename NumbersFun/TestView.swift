//
//  TestView.swift
//  NumbersFun
//
//  Created by Дмитрий Куприянов on 7.03.25.
//

import SwiftUI

struct TestView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var drawView = DrawView()
    @State private var testDigits: [Int] = (0..<10).shuffled()
    @State private var currentIndex = 0
    @State private var correctAnswers = 0
    @State private var showResult = false

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
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 30))
                            .foregroundColor(.black)
                    }
                }

                Text("Начертайте цифрa: \(testDigits[currentIndex])")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.top, geometry.size.height * 0.1)

                DrawViewRepresentable(drawView: $drawView, selectedDigit: testDigits[currentIndex])
                    .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9)
                    .background(Color(levelColors[testDigits[currentIndex]]))
                    .cornerRadius(20)
                    .padding(.bottom, 20)

                HStack {
                    Button("Изтрий") {
                        drawView.clear(backgroundColor: levelColors[testDigits[currentIndex]])
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    Button("Провери") {
                        checkAnswer()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 20)
            .padding(.bottom, geometry.size.height * 0.2)
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
    }

    func checkAnswer() {
        guard let context = drawView.getViewContext(), let pixelBuffer = createPixelBuffer(from: context) else {
            return
        }

        let model = try? mnistCNN(configuration: .init())
        let output = try? model?.prediction(image: pixelBuffer)
        let predictedDigit = output?.classLabel ?? "?"

        if let predictedInt = Int(predictedDigit), predictedInt == testDigits[currentIndex] {
            correctAnswers += 1
        }

        if currentIndex < 9 {
            currentIndex += 1
            drawView.clear(backgroundColor: levelColors[testDigits[currentIndex]])
        } else {
            showResult = true
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
}
