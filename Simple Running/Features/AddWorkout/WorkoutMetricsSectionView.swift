//
//  WorkoutMetricsSectionView.swift
//  Simple Running
//
//  Created by Gustavo Monteiro on 28/05/25.
//

import SwiftUI

struct WorkoutMetricsSectionView: View {
    @Binding var durationMinutesString: String
    @Binding var distanceKmString: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Métricas (Opcional)")
                .font(.title3)
                .fontWeight(.semibold)
                .padding([.top, .leading, .trailing])
                .padding(.bottom, 8)
            
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(.accentColor)
                Text("Duração (minutos)")
                    .font(.callout)
                Spacer()
                TextField("Ex: 30", text: $durationMinutesString)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .padding(.vertical, 4)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            Divider().padding(.leading)
            
            HStack {
                Image(systemName: "ruler")
                    .foregroundColor(.accentColor)
                Text("Distância (km)")
                    .font(.callout)
                Spacer()
                TextField("Ex: 5.5", text: $distanceKmString)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .padding(.vertical, 4)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}
