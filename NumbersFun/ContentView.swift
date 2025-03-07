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
                Spacer()
                    .frame(height: geometry.size.height * 0.1)
                
                Text("Начертайте цифра: \(selectedDigit)")
                    .font(.title)
                    .padding(.top, 10)
                
                GeometryReader { geometry in
                    VStack {
                        DrawViewRepresentable(drawView: $drawView, selectedDigit: selectedDigit)
                            .frame(width: geometry.size.width * 0.92, height: geometry.size.width * 0.92)
                            .background(Color.black)
                            .cornerRadius(20)
                            .padding(geometry.size.width * 0.04)
                    }
                    
                }
                .padding(.bottom, 20)
                
                HStack {
                    Button("Изтрий") {
                        drawView.clear(backgroundColor: levelColors[selectedDigit])
                        predictionResult = "Разпозната цифра: ?"
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Провери") {
                        predictDigit()
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                    
                    Text(predictionResult)
                        .font(.headline)
                        .padding(.top, 15)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(0..<10) { digit in
                                Button(action: {
                                    selectedDigit = digit
                                    drawView.clear(backgroundColor: levelColors[digit])
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
                        .padding(.horizontal,20)
                    }
                    .padding(.top, 35)
                    
                
                    Spacer()
                        .frame(height: geometry.size.height * 0.1)
                }
            }
            .edgesIgnoringSafeArea(.all)
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
