//
//  PrescriptionUploadView.swift
//  ClinicFlow
//

import SwiftUI

struct PrescriptionUploadView: View {
    @EnvironmentObject var hapticsManager: HapticsManager
    
    let serviceTitle: String
    @Binding var prescriptionImage: UIImage?
    @Binding var notes: String
    @Binding var showingImagePicker: Bool
    let onContinue: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.image")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(Color(hex: "16A34A"))
                    
                    Text("Upload Prescription")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Required for \(serviceTitle) services")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Upload Section
                VStack(spacing: 20) {
                    if let image = prescriptionImage {
                        // Show uploaded image
                        VStack(spacing: 16) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            HStack(spacing: 12) {
                                Button(action: {
                                    hapticsManager.playTapSound()
                                    showingImagePicker = true
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Change")
                                            .font(.system(size: 15, weight: .semibold))
                                    }
                                    .foregroundColor(Color(hex: "16A34A"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "16A34A").opacity(0.1))
                                    .clipShape(Capsule())
                                }
                                
                                Button(action: {
                                    hapticsManager.playTapSound()
                                    prescriptionImage = nil
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Remove")
                                            .font(.system(size: 15, weight: .semibold))
                                    }
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.red.opacity(0.1))
                                    .clipShape(Capsule())
                                }
                            }
                        }
                    } else {
                        // Upload placeholder
                        Button(action: {
                            hapticsManager.playTapSound()
                            showingImagePicker = true
                        }) {
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "16A34A").opacity(0.1))
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 36, weight: .medium))
                                        .foregroundColor(Color(hex: "16A34A"))
                                }
                                
                                VStack(spacing: 6) {
                                    Text("Tap to Upload")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text("Select prescription from gallery")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(hex: "16A34A").opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
                            )
                        }
                    }
                }
                .padding(20)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                
                // Notes Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 10) {
                        Image(systemName: "note.text")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "16A34A"))
                        
                        Text("Additional Notes")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("(Optional)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    TextEditor(text: $notes)
                        .frame(height: 120)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                .padding(20)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                
                // Info Note
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "16A34A"))
                    
                    Text("Make sure the prescription is clear and all details are visible")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color(hex: "16A34A").opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                // Back Button
                Button(action: {
                    hapticsManager.playTapSound()
                    onBack()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "16A34A"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(hex: "16A34A").opacity(0.1))
                    .clipShape(Capsule())
                }
                
                // Continue Button
                Button(action: {
                    hapticsManager.playConfirmSound()
                    onContinue()
                }) {
                    HStack(spacing: 10) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(prescriptionImage != nil ? Color(hex: "16A34A") : Color(.systemGray4))
                    .clipShape(Capsule())
                    .shadow(color: prescriptionImage != nil ? Color(hex: "16A34A").opacity(0.35) : Color.clear, radius: 10, x: 0, y: 4)
                }
                .disabled(prescriptionImage == nil)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .background(
                Color(.systemBackground)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: -4)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }
}
