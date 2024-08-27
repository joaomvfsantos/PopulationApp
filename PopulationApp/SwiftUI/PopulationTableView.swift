//
//  PopulationTableView.swift
//  PopulationApp
//
//  Created by João Santos on 27/08/2024.
//

import SwiftUI

class TableData: ObservableObject {
    @Published var items: [TableItem] = []
    
    init(items: [TableItem]) {
        self.items = items
    }
}

struct TableItem: Identifiable {
    var id = UUID()
    
    var location: String
    var population: Int
    var year: Int
}

struct PopulationTableView: View {
    @EnvironmentObject private var data: TableData
    @State private var sortOrder = [
        KeyPathComparator(\TableItem.location)
    ]
    @Environment(\.horizontalSizeClass) var sizeCategory
    
    var body: some View {
        Table(data.items, sortOrder: $sortOrder) {
            TableColumn("Location", value: \.location) { item in
                if (sizeCategory == .compact) {
                    VStack(alignment: .leading) {
                        Text(item.location)
                            .bold()
                        HStack {
                            Text("Population:")
                            Text(item.population, format: .number)
                        }
                    }
                     
                 } else {
                     Text(item.location)
                 }
                
            }
            TableColumn("Population", value: \.population) { item in
                Text(String(item.population))
            }
            TableColumn("Year", value: \.year) { item in
                Text(String(item.year))
            }
        }
        .onChange(of: sortOrder) { _, sortOrder in
            data.items.sort(using: sortOrder)
        }
    }
}

#Preview {
    PopulationTableView()
        .environmentObject(TableData(items: [
            TableItem(location: "Alabama", population: 5028092, year: 2022),
            TableItem(location: "Alaska", population: 734821, year: 2022),
            TableItem(location: "New Jersey", population: 9249063, year: 2022),
        ]))
}
