//
//  WorkoutDetailSectionView.swift
//  Simple Running
//
//  Created by Gustavo Monteiro on 28/05/25.
//

import SwiftUI

struct WorkoutDetailSectionView: View {
    @Binding var date: Date
    @Binding var description: String
    @Binding var type: WorkoutType
    let futureDateRange: ClosedRange<Date>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Detalhes do Treino")
                .font(.title3)
                .fontWeight(.semibold)
                .padding([.top, .leading, .trailing])
                .padding(.bottom, 8)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.accentColor)
                Text("Data")
                    .font(.callout)
                Spacer()
                DatePicker("", selection: $date, in: futureDateRange, displayedComponents: .date)
                    .labelsHidden()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            Divider().padding(.leading)
            
            HStack {
                Image(systemName: type.iconName) // Certifique-se que WorkoutType.iconName existe
                    .foregroundColor(.accentColor)
                Text("Tipo de Treino")
                    .font(.callout)
                Spacer()
                Picker("", selection: $type) {
                    ForEach(WorkoutType.allCases) { workoutType in // Certifique-se que WorkoutType.allCases existe
                        Text(workoutType.rawValue).tag(workoutType)
                    }
                }
                .labelsHidden()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            Divider().padding(.leading)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "text.bubble")
                        .foregroundColor(.accentColor)
                    Text("Descrição")
                        .font(.callout)
                }
                TextEditor(text: $description)
                    .frame(height: 100)
                    .background(Color(UIColor.systemBackground)) // Use Color(.systemBackground) para consistência
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}
