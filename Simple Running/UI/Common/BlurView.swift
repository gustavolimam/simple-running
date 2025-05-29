//
//  BlurView.swift
//  Simple Running
//
//  Created by Gustavo Monteiro on 16/05/25.
//

import SwiftUI

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct BlurView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Image(systemName: "photo.fill")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Text("Texto sobre o Blur testando a qualidade do efeito")
                .padding()
                .background(BlurView(style: .systemMaterial))
                .cornerRadius(10)
        }
    }
}
