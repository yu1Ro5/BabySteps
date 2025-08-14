import SwiftUI

struct Milestone: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let age: String
    let isCompleted: Bool
    let icon: String
}

struct MilestoneView: View {
    @State private var milestones: [Milestone] = [
        Milestone(title: "First Smile", description: "Baby's first social smile", age: "6-8 weeks", isCompleted: true, icon: "face.smiling"),
        Milestone(title: "First Laugh", description: "Baby's first giggle", age: "3-4 months", isCompleted: true, icon: "face.smiling.inverse"),
        Milestone(title: "Rolling Over", description: "Baby rolls from tummy to back", age: "4-6 months", isCompleted: false, icon: "arrow.clockwise"),
        Milestone(title: "Sitting Up", description: "Baby sits without support", age: "6-8 months", isCompleted: false, icon: "figure.seated.side"),
        Milestone(title: "First Word", description: "Baby says first word", age: "10-14 months", isCompleted: false, icon: "text.bubble"),
        Milestone(title: "First Steps", description: "Baby takes first steps", age: "9-15 months", isCompleted: false, icon: "figure.walk")
    ]
    
    var body: some View {
        List {
            ForEach(milestones) { milestone in
                HStack {
                    Image(systemName: milestone.icon)
                        .font(.title2)
                        .foregroundColor(milestone.isCompleted ? .green : .gray)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(milestone.title)
                            .font(.headline)
                        Text(milestone.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Expected: \(milestone.age)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    if milestone.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Button(action: {
                            if let index = milestones.firstIndex(where: { $0.id == milestone.id }) {
                                milestones[index] = Milestone(
                                    title: milestone.title,
                                    description: milestone.description,
                                    age: milestone.age,
                                    isCompleted: true,
                                    icon: milestone.icon
                                )
                            }
                        }) {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Milestones")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct MilestoneView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MilestoneView()
        }
    }
}