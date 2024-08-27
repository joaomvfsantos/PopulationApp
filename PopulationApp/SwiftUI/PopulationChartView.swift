//
//  PopulationChartView.swift
//  PopulationApp
//
//  Created by João Santos on 27/08/2024.
//

import SwiftUI
import Charts

class PopulationChartData: ObservableObject {
    @Published var items: [PopulationChartItem]
    
    init(items: [PopulationChartItem]) {
        self.items = items
    }
}

struct PopulationChartItem: Identifiable {
    var id = UUID()
    
    var year: Int
    var population: Int
}

struct PopulationChartView: View {
    
    @EnvironmentObject private var data: PopulationChartData
    
    var body: some View {
        let color: Color = Color(hue: 0.33, saturation: 0.81, brightness: 0.76)
        let curGradient = LinearGradient(
            gradient: Gradient (
                colors: [
                    color.opacity(0.5),
                    color.opacity(0.2),
                    color.opacity(0.05),
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
        
        VStack {
            Chart(data.items) {
                LineMark(
                    x: .value("Year", $0.year),
                    y: .value("Population", $0.population)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                AreaMark(
                    x: .value("Year", $0.year),
                    y: .value("Population", $0.population)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(curGradient)
            }
            .chartYScale(type: .linear)
            .chartXScale(domain: [
                data.items.map({$0.year}).min() ?? 0,
                data.items.map({$0.year}).max() ?? 0,
            ])
            .chartYAxisLabel("Population in Millions")
            .chartXAxisLabel("Years")
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic) { value in
                    AxisGridLine()
                    if let pop = value.as(Int.self) {
                        let div = Double(pop) / 1000000
                        AxisValueLabel() {
                            Text(div, format: .number)
                        }
                    }
                }
            }
        }.padding()
    }
}

#Preview {
    PopulationChartView().environmentObject(PopulationChartData(items: [
        PopulationChartItem(year: 2022, population: 331097593),
        PopulationChartItem(year: 2021, population: 329725481),
        PopulationChartItem(year: 2020, population: 324697795),
    ]))
}
