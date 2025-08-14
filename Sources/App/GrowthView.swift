import SwiftUI

struct GrowthRecord: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
    let height: Double
    let headCircumference: Double
}

struct GrowthView: View {
    @State private var growthRecords: [GrowthRecord] = [
        GrowthRecord(date: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(), weight: 3.2, height: 50.0, headCircumference: 35.0),
        GrowthRecord(date: Calendar.current.date(byAdding: .day, value: -20, to: Date()) ?? Date(), weight: 3.8, height: 52.0, headCircumference: 36.0),
        GrowthRecord(date: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(), weight: 4.2, height: 54.0, headCircumference: 37.0),
        GrowthRecord(date: Date(), weight: 4.5, height: 55.0, headCircumference: 37.5)
    ]
    
    @State private var showingAddRecord = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Summary Cards
                HStack(spacing: 15) {
                    GrowthCard(title: "Weight", value: "\(growthRecords.last?.weight ?? 0, specifier: "%.1f) kg", color: .blue)
                    GrowthCard(title: "Height", value: "\(growthRecords.last?.height ?? 0, specifier: "%.1f) cm", color: .green)
                }
                
                HStack(spacing: 15) {
                    GrowthCard(title: "Head", value: "\(growthRecords.last?.headCircumference ?? 0, specifier: "%.1f) cm", color: .orange)
                    GrowthCard(title: "Age", value: "\(Calendar.current.dateComponents([.day], from: growthRecords.first?.date ?? Date(), to: Date()).day ?? 0) days", color: .purple)
                }
                
                // Growth Chart
                VStack(alignment: .leading, spacing: 10) {
                    Text("Growth Progress")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(growthRecords) { record in
                                VStack(spacing: 8) {
                                    VStack(spacing: 4) {
                                        Text("\(record.weight, specifier: "%.1f)")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                        Text("kg")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Rectangle()
                                        .fill(Color.blue)
                                        .frame(width: 30, height: CGFloat(record.weight * 10))
                                        .cornerRadius(4)
                                    
                                    Text(record.date, style: .date)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Records List
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Growth Records")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            showingAddRecord = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal)
                    
                    ForEach(growthRecords.sorted(by: { $0.date > $1.date })) { record in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(record.date, style: .date)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                HStack(spacing: 15) {
                                    Label("\(record.weight, specifier: "%.1f) kg", systemImage: "scalemass")
                                    Label("\(record.height, specifier: "%.1f) cm", systemImage: "ruler")
                                    Label("\(record.headCircumference, specifier: "%.1f) cm", systemImage: "circle")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Growth Tracking")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingAddRecord) {
            AddGrowthRecordView(growthRecords: $growthRecords)
        }
    }
}

struct GrowthCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AddGrowthRecordView: View {
    @Binding var growthRecords: [GrowthRecord]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var weight = ""
    @State private var height = ""
    @State private var headCircumference = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Growth Record")) {
                    HStack {
                        Text("Weight (kg)")
                        Spacer()
                        TextField("0.0", text: $weight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Height (cm)")
                        Spacer()
                        TextField("0.0", text: $height)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Head Circumference (cm)")
                        Spacer()
                        TextField("0.0", text: $headCircumference)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Add Record")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    if let weightValue = Double(weight),
                       let heightValue = Double(height),
                       let headValue = Double(headCircumference) {
                        let newRecord = GrowthRecord(
                            date: Date(),
                            weight: weightValue,
                            height: heightValue,
                            headCircumference: headValue
                        )
                        growthRecords.append(newRecord)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
}

struct GrowthView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GrowthView()
        }
    }
}