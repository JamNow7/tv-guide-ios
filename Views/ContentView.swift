//
//  ContentView.swift
//  Guía TV
//
//  Created by Claudio Cataldo on 19-06-26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = TVGuideViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "Todos", isSelected: vm.selectedNetwork == nil) {
                            vm.selectedNetwork = nil
                        }

                        ForEach(vm.availableNetworks, id: \.self) { network in
                            FilterChip(title: network, isSelected: vm.selectedNetwork == network) {
                                vm.selectedNetwork = network
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color.systemGroupedBackground)

                // Lista de programas
                List(vm.filteredPrograms) { program in
                    NavigationLink(destination: ProgramDetailView(program: program)) {
                        HStack(alignment: .top, spacing: 12) {
                            // Imagen del show
                            AsyncImage(url: URL(string: program.imageURL ?? "")) { phase in
                                switch phase {
                                case .empty:
                                    Color.gray.opacity(0.2)
                                        .frame(width: 80, height: 120)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                case .failure:
                                    Color.gray.opacity(0.2)
                                        .frame(width: 80, height: 120)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .foregroundColor(.gray)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                @unknown default:
                                    Color.gray.opacity(0.2)
                                        .frame(width: 80, height: 120)
                                }
                            }
                            .frame(width: 80, height: 120)

                            // Información del programa
                            VStack(alignment: .leading, spacing: 4) {
                                Text(program.showName)
                                    .font(.headline)

                                Text(program.name)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                // Badges
                                FlowLayout(spacing: 4) {
                                    if let season = program.season, let number = program.number {
                                        Text("S\(season)E\(number)")
                                            .font(.caption)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.2))
                                            .clipShape(Capsule())
                                    }

                                    if let type = program.type, !type.isEmpty {
                                        Text(type.capitalized)
                                            .font(.caption)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.green.opacity(0.2))
                                            .clipShape(Capsule())
                                    }

                                    if let rating = program.rating {
                                        HStack(spacing: 2) {
                                            Image(systemName: "star.fill")
                                                .font(.caption2)
                                            Text(String(format: "%.1f", rating))
                                                .font(.caption)
                                        }
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.yellow.opacity(0.2))
                                        .clipShape(Capsule())
                                    }

                                    if let network = program.networkName {
                                        Text(network)
                                            .font(.caption)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.purple.opacity(0.2))
                                            .clipShape(Capsule())
                                    }
                                }

                                // Fecha y hora
                                HStack(spacing: 6) {
                                    Text(program.airdate)
                                        .font(.caption)
                                        .foregroundColor(.blue)

                                    Text("•")
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    Text(program.airtime)
                                        .font(.caption)
                                        .foregroundColor(.blue)

                                    if let runtime = program.runtime {
                                        Text("•")
                                            .font(.caption)
                                            .foregroundColor(.gray)

                                        Text("\(runtime)m")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }

                                if let summary = program.summary, !summary.isEmpty {
                                    Text(summary.stripHTML())
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(3)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("TV Guide")
            .task {
                await vm.load()
            }
        }
    }
}

// Filter Chip - Botón elegante de filtro
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}

// FlowLayout simple para badges con wrapping
struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                     y: bounds.minY + result.positions[index].y),
                        proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))

                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// Extension para color de fondo agrupado
extension Color {
    static var systemGroupedBackground: Color {
        Color(UIColor.systemGroupedBackground)
    }
}
