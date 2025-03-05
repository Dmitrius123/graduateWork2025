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

    let model = mnistCNN()

    var body: some View {
        VStack {
            // Представление для рисования
            DrawViewRepresentable(drawView: $drawView)
                .frame(width: 300, height: 300)
                .background(Color.black)
                .border(Color.white, width: 2)
                .onAppear {}

            HStack {
                Button("Изтрий") {
                    drawView.clear()  // Очистить линию
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
                .padding()
        }
    }

    func predictDigit() {
        guard let context = drawView.getViewContext(), let pixelBuffer = createPixelBuffer(from: context) else {
            return
        }

        let output = try? model.prediction(image: pixelBuffer)
        predictionResult = "Разпозната цифра: \(output?.classLabel ?? "Error")"
    }

    func createPixelBuffer(from context: CGContext) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        CVPixelBufferCreate(kCFAllocatorDefault, 28, 28, kCVPixelFormatType_OneComponent8, attrs, &pixelBuffer)

        guard let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)

        context.drawPath(using: .fill)
        let cgImage = context.makeImage()

        let ciImage = CIImage(cgImage: cgImage!)
        let ciContext = CIContext()
        ciContext.render(ciImage, to: buffer)

        CVPixelBufferUnlockBaseAddress(buffer, [])
        return buffer
    }
}

struct DrawViewRepresentable: UIViewRepresentable {
    @Binding var drawView: DrawView

    func makeUIView(context: Context) -> DrawView {
        return drawView
    }

    func updateUIView(_ uiView: DrawView, context: Context) {
    }
}
