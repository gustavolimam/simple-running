//
//  MainTabView.swift
//  Simple Running
//
//  Created by Gustavo Monteiro on 16/05/25.
//

import SwiftUI

/// Uma view de container que gerencia a navegação por abas e exibe o conteúdo da aba selecionada.
struct MainTabView<Content: View>: View {
    @Binding var selectedTab: TabItem
    let content: (TabItem) -> Content // Closure para fornecer o conteúdo da view para cada aba

    init(selectedTab: Binding<TabItem>, @ViewBuilder content: @escaping (TabItem) -> Content) {
        self._selectedTab = selectedTab
        self.content = content
    }

    var body: some View {
        ZStack {
            // Conteúdo da aba selecionada
            Group {
                content(selectedTab)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground).ignoresSafeArea()) // Garante que o fundo da view da aba preencha

            // TabBar customizada
            VStack {
                Spacer() // Empurra a TabBar para baixo
                customTabBar
            }
        }
        .background(
            .ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10)
        )
        .ignoresSafeArea(.keyboard) // Para evitar que o teclado sobreponha a TabBar
    }

    private var customTabBar: some View {
        HStack {
            ForEach(TabItem.allCases, id: \.self) { tab in
                TabBarButtonView(tabItem: tab, selectedTab: $selectedTab) {
                    selectedTab = tab
                }
                if tab != TabItem.allCases.last { // Adiciona Spacer exceto para o último item
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            BlurView(style: .systemUltraThinMaterial)
                .background(Color.white.opacity(0.15)) // Efeito de vidro sutil
                .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
                .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 8) // Espaçamento nas laterais da TabBar
        .padding(.bottom, 8)     // Espaçamento inferior para a safe area ou elementos abaixo
    }
}

struct MainTabView_Previews: PreviewProvider {
    struct PreviewContentView: View {
        var tabItem: TabItem
        var body: some View {
            VStack {
                Text("\(tabItem.label) View")
                    .font(.largeTitle)
                Image(systemName: tabItem.systemImageName)
                    .font(.largeTitle)
                    .padding()
            }
        }
    }

    static var previews: some View {
        StatefulPreviewWrapper(TabItem.today) { selection in
            MainTabView(selectedTab: selection) { tab in
                PreviewContentView(tabItem: tab)
            }
        }
    }
}
