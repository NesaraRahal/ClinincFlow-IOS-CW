import SwiftUI

// MARK: - Terms & Privacy View
struct TermsPrivacyView: View {
    var body: some View {
        List {
            Section {
                NavigationLink {
                    LegalDocumentView(
                        title: "Terms of Service",
                        lastUpdated: "February 1, 2026",
                        content: termsContent
                    )
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Terms of Service")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Text("Last updated: Feb 1, 2026")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                NavigationLink {
                    LegalDocumentView(
                        title: "Privacy Policy",
                        lastUpdated: "February 1, 2026",
                        content: privacyContent
                    )
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green.opacity(0.15))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.green)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Privacy Policy")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Text("Last updated: Feb 1, 2026")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Section {
                NavigationLink {
                    DataPrivacyView()
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.purple.opacity(0.15))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.purple)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Data & Privacy")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Text("Manage your data preferences")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Terms & Privacy")
        .navigationBarTitleDisplayMode(.large)
    }
    
    var termsContent: String {
        """
        Welcome to ClinicFlow. By using our application, you agree to be bound by these Terms of Service.

        1. ACCEPTANCE OF TERMS
        By accessing and using ClinicFlow, you acknowledge that you have read, understood, and agree to be bound by these terms.

        2. USE OF SERVICE
        ClinicFlow provides healthcare appointment booking and queue management services. You agree to use the service only for lawful purposes.

        3. USER ACCOUNTS
        You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.

        4. MEDICAL DISCLAIMER
        ClinicFlow is a scheduling and queue management tool only. It does not provide medical advice, diagnosis, or treatment.

        5. PRIVACY
        Your privacy is important to us. Please review our Privacy Policy to understand how we collect and use your information.

        6. CHANGES TO TERMS
        We reserve the right to modify these terms at any time. Continued use of the service constitutes acceptance of modified terms.
        """
    }
    
    var privacyContent: String {
        """
        ClinicFlow is committed to protecting your privacy. This policy explains how we handle your personal information.

        1. INFORMATION WE COLLECT
        • Personal information (name, contact details)
        • Health-related information for appointments
        • Device and usage information

        2. HOW WE USE YOUR INFORMATION
        • To provide and improve our services
        • To communicate appointment updates
        • To ensure the security of our platform

        3. DATA SHARING
        We do not sell your personal information. We share data only with healthcare providers you choose to visit.

        4. DATA SECURITY
        We implement industry-standard security measures to protect your information.

        5. YOUR RIGHTS
        You have the right to access, correct, or delete your personal information at any time.

        6. CONTACT US
        For privacy-related inquiries, contact us at privacy@clinicflow.com
        """
    }
}

// MARK: - Legal Document View
struct LegalDocumentView: View {
    let title: String
    let lastUpdated: String
    let content: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Last updated: \(lastUpdated)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(content)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.primary)
                    .lineSpacing(6)
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Data Privacy View
struct DataPrivacyView: View {
    @State private var analyticsEnabled = true
    @State private var personalizedContent = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        List {
            Section {
                Toggle(isOn: $analyticsEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Analytics")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("Help improve the app by sharing usage data")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                }
                .tint(Color(hex: "16A34A"))
                
                Toggle(isOn: $personalizedContent) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Personalized Content")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("Receive tailored health tips and reminders")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                }
                .tint(Color(hex: "16A34A"))
            } header: {
                Text("Data Preferences")
            }
            
            Section {
                Button(action: {}) {
                    HStack {
                        Text("Download My Data")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "16A34A"))
                        
                        Spacer()
                        
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(Color(hex: "16A34A"))
                    }
                }
            } footer: {
                Text("Request a copy of all your personal data")
            }
            
            Section {
                Button(action: {
                    showDeleteAlert = true
                }) {
                    HStack {
                        Text("Delete All My Data")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                        
                        Spacer()
                        
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                    }
                }
            } footer: {
                Text("This will permanently delete all your data from our servers. This action cannot be undone.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Data & Privacy")
        .navigationBarTitleDisplayMode(.large)
        .alert("Delete All Data", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // Handle delete
            }
        } message: {
            Text("This will permanently delete all your data. Are you sure you want to continue?")
        }
    }
}

#Preview {
    NavigationStack {
        TermsPrivacyView()
    }
}
