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
    let model = try? mnistCNN(configuration: .init())

    // Темные цвета через RGB
    let levelColors: [UIColor] = [
        UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1), // Очень темный серый
        UIColor(red: 10/255, green: 0/255, blue: 50/255, alpha: 1),  // Темно-синий
        UIColor(red: 40/255, green: 0/255, blue: 40/255, alpha: 1),  // Темно-фиолетовый
        UIColor(red: 0/255, green: 50/255, blue: 0/255, alpha: 1),   // Темно-зеленый
        UIColor(red: 50/255, green: 0/255, blue: 0/255, alpha: 1),   // Темно-красный
        UIColor(red: 40/255, green: 40/255, blue: 0/255, alpha: 1),  // Темно-желтый
        UIColor(red: 50/255, green: 0/255, blue: 50/255, alpha: 1),  // Темно-фиолетовый
        UIColor(red: 0/255, green: 0/255, blue: 50/255, alpha: 1),   // Темно-синий
        UIColor(red: 0/255, green: 50/255, blue: 50/255, alpha: 1),  // Темно-голубой
        UIColor(red: 20/255, green: 0/255, blue: 20/255, alpha: 1)   // Темно-бордовый
    ]

    var body: some View {
        VStack {
            Text("Начертайте цифра: \(selectedDigit)")
                .font(.title)
                .padding()

            // Передаем selectedDigit в DrawViewRepresentable
            DrawViewRepresentable(drawView: $drawView, selectedDigit: selectedDigit)
                .frame(width: 300, height: 300)
                .background(Color.black)
                .border(Color.white, width: 2)

            HStack {
                Button("Изтрий") {
                    // Используем UIColor для установки цвета фона
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

            Text(predictionResult)
                .font(.headline)
                .padding()

            // Кнопки для выбора цифры
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(0..<10) { digit in
                        Button(action: {
                            selectedDigit = digit
                            // Устанавливаем темный цвет фона через UIColor
                            drawView.clear(backgroundColor: levelColors[digit])
                        }) {
                            Text("\(digit)")
                                .font(.title)
                                .frame(width: 50, height: 50)
                                .background(selectedDigit == digit ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
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
}
