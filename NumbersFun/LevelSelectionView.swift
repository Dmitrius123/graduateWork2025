//
//  LevelSelectionView.swift
//  NumbersFun
//
//  Created by Дмитрий Куприянов on 7.03.25.
//

import SwiftUI

struct LevelSelectionView: View {
    @Binding var selectedDigit: Int

    let levelColors: [Color] = [
        .red, .blue, .green, .yellow, .purple,
        .orange, .pink, .gray, .cyan, .brown
    ]

    var body: some View {
        VStack {
            Text("Выберите уровень (цифру):")
                .font(.title)
                .padding()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(0..<10) { digit in
                        Button(action: {
                            selectedDigit = digit
                        }) {
                            Text("\(digit)")
                                .font(.title)
                                .frame(width: 50, height: 50)
                                .background(levelColors[digit]) // Цвет фона для цифры
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
        }
    }
}
