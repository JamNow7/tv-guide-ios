//
//  SkeletonLoadingView.swift
//  Guía TV
//
//  Created by Claudio Cataldo on 19-06-26.
//  Vista de carga moderna con efecto skeleton
//

import SwiftUI

/// Vista de carga con efecto skeleton shimmer
/// Muestra placeholders animados mientras se cargan los datos
struct SkeletonLoadingView: View {
    @State private var isAnimating = false

    private let shimmerGradient = LinearGradient(
        colors: [
            .gray.opacity(0.3),
            .gray.opacity(0.5),
            .gray.opacity(0.3)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(0..<5, id: \.self) { _ in
                    SkeletonRow()
                }
            }
            .padding(.vertical)
        }
        .opacity(isAnimating ? 1.0 : 0.5)
        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

/// Fila individual del skeleton loading
/// Representa un programa con imagen y texto
struct SkeletonRow: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Skeleton imagen
            RoundedRectangle(cornerRadius: 8)
                .fill(.gray.opacity(0.3))
                .frame(width: 80, height: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            LinearGradient(
                                colors: [Color.clear, Color.white.opacity(0.3), Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                        .offset(x: isAnimating ? 150 : -150)
                )
                .clipped()
                .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating)

            // Skeleton texto
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.gray.opacity(0.3))
                    .frame(height: 16)
                    .frame(maxWidth: 200)

                RoundedRectangle(cornerRadius: 4)
                    .fill(.gray.opacity(0.3))
                    .frame(height: 12)
                    .frame(maxWidth: 150)

                RoundedRectangle(cornerRadius: 4)
                    .fill(.gray.opacity(0.3))
                    .frame(height: 12)
                    .frame(maxWidth: 180)

                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.gray.opacity(0.3))
                        .frame(width: 40, height: 12)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(.gray.opacity(0.3))
                        .frame(width: 30, height: 12)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(.gray.opacity(0.3))
                        .frame(width: 50, height: 12)
                }
            }
        }
        .padding(.horizontal)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Preview

#Preview {
    SkeletonLoadingView()
}
