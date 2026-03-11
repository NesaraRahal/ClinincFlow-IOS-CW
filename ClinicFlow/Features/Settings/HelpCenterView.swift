import SwiftUI

// MARK: - Help Center View
struct HelpCenterView: View {
    @State private var searchText = ""
    
    let faqItems = [
        FAQItem(question: "How do I book an appointment?", answer: "Navigate to the Home tab, select a service (OPD, Laboratory, etc.), choose your preferred doctor or staff, and select an available time slot."),
        FAQItem(question: "How do I check my queue status?", answer: "Your current queue status is displayed on the Home screen after checking in. You can see your token number, patients ahead, and estimated wait time."),
        FAQItem(question: "Can I book for family members?", answer: "Yes! Go to Settings > Family Members to add family profiles. You can then book appointments on their behalf."),
        FAQItem(question: "How do I cancel an appointment?", answer: "Go to My Visits, tap on the appointment you want to cancel, and select 'Cancel Appointment'."),
        FAQItem(question: "How does indoor navigation work?", answer: "After checking in, tap on 'Get Directions' in the Location card on your Home screen to view step-by-step directions to your room.")
    ]
    
    var filteredFAQs: [FAQItem] {
        if searchText.isEmpty {
            return faqItems
        }
        return faqItems.filter { $0.question.localizedCaseInsensitiveContains(searchText) || $0.answer.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        List {
            Section {
                ForEach(filteredFAQs) { item in
                    NavigationLink {
                        FAQDetailView(item: item)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.question)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text(item.answer)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 6)
                    }
                }
            } header: {
                Text("Frequently Asked Questions")
            }
            
            Section {
                NavigationLink {
                    ContactUsView()
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "16A34A").opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "16A34A"))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Still need help?")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Contact our support team")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, prompt: "Search help topics")
        .navigationTitle("Help Center")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - FAQ Item
struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

// MARK: - FAQ Detail View
struct FAQDetailView: View {
    let item: FAQItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(item.question)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(item.answer)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineSpacing(6)
                
                Divider()
                    .padding(.vertical, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Was this helpful?")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            HStack(spacing: 6) {
                                Image(systemName: "hand.thumbsup.fill")
                                Text("Yes")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "16A34A"))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(hex: "16A34A").opacity(0.1))
                            .clipShape(Capsule())
                        }
                        
                        Button(action: {}) {
                            HStack(spacing: 6) {
                                Image(systemName: "hand.thumbsdown.fill")
                                Text("No")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("FAQ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HelpCenterView()
    }
}
