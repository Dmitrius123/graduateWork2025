//
//  RootView.swift
//  NumbersFun
//
//  Created by Дмитрий Куприянов on 5.04.25.
//

import SwiftUI

struct RootView: View {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @State private var showStartView = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
    @State private var animateExit = false
    
    var body: some View {
        ZStack {
            ContentView()
            
            if showStartView {
                StartView(onStart: {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        animateExit = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                        showStartView = false
                    }
                })
                .opacity(animateExit ? 0 : 1)
                .transition(.move(edge: .top))
            }
        }
        .animation(.easeInOut(duration: 0.8), value: showStartView)
    }
}

struct StartView: View {
    var onStart: () -> Void
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Text("NumbersFun")
                    .font(.custom("Marker Felt", size: 60))
                    .foregroundColor(.purple)
                
                Text("Дипломна работа\nДмитрий Куприянов")
                    .font(.custom("Marker Felt", size: 30))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Button(action: onStart) {
                    Text("Към начало")
                        .font(.custom("Marker Felt", size: 30))
                        .padding(.horizontal, 50)
                        .padding(.vertical, 15)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
                .padding(.bottom, 60)
            }
            .padding()
        }
    }
}

#Preview {
    RootView()
}
