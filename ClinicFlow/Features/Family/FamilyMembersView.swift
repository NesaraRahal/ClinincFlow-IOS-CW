//
//  FamilyMembersView.swift
//  ClinicFlow
//

import SwiftUI

// MARK: - Family Members View
// Manage family member profiles
struct FamilyMembersView: View {
    @EnvironmentObject var familyManager: FamilyMembersManager
    @EnvironmentObject var hapticsManager: HapticsManager
    @State private var showAddMember = false
    
    var body: some View {
        VStack(spacing: 0) {
            if familyManager.members.isEmpty {
                // Empty State
                Spacer()
                
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "person.2")
                            .font(.system(size: 32))
                            .foregroundColor(Color(.systemGray3))
                    }
                    
                    Text("No Family Members")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Add family members to book\nappointments on their behalf")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        hapticsManager.playTapSound()
                        showAddMember = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16))
                            Text("Add Family Member")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Color(hex: "16A34A"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.top, 8)
                }
                
                Spacer()
            } else {
                // Members List
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(familyManager.members) { member in
                            FamilyMemberRow(member: member)
                        }
                        .onDelete { offsets in
                            familyManager.removeMember(at: offsets)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Family Members")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    hapticsManager.playTapSound()
                    showAddMember = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "16A34A"))
                }
            }
        }
        .sheet(isPresented: $showAddMember) {
            AddFamilyMemberView()
        }
    }
}

// MARK: - Family Member Row
struct FamilyMemberRow: View {
    let member: FamilyMember
    
    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [member.iconColor, member.iconColor.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Text(member.initials)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(member.fullName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("\(member.relationship) • \(member.age) yrs")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(.systemGray3))
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Add Family Member View
struct AddFamilyMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var familyManager: FamilyMembersManager
    @EnvironmentObject var hapticsManager: HapticsManager
    
    @State private var name = ""
    @State private var relationship = "Spouse"
    @State private var age = ""
    @State private var gender = "Male"
    @State private var bloodType = ""
    
    let relationships = ["Spouse", "Parent", "Child", "Sibling", "Other"]
    let genders = ["Male", "Female", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Details") {
                    TextField("Full Name", text: $name)
                    
                    Picker("Relationship", selection: $relationship) {
                        ForEach(relationships, id: \.self) { rel in
                            Text(rel).tag(rel)
                        }
                    }
                    
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(genders, id: \.self) { g in
                            Text(g).tag(g)
                        }
                    }
                }
            }
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        let member = FamilyMember(
                            fullName: name,
                            relationship: relationship,
                            age: Int(age) ?? 0,
                            gender: gender,
                            bloodType: bloodType
                        )
                        familyManager.addMember(member)
                        hapticsManager.playSuccessSound()
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "16A34A"))
                    .disabled(name.isEmpty || age.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FamilyMembersView()
    }
    .environmentObject(FamilyMembersManager())
    .environmentObject(HapticsManager())
}
