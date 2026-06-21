//
//  ContentView.swift
//  Guía TV
//
//  Created by Claudio Cataldo on 19-06-26.
//  Vista principal con búsqueda, filtros y estados de carga/error
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm: TVGuideViewModel

    init() {
        let service = DependencyContainer.shared.tvService
        _vm = StateObject(wrappedValue: TVGuideViewModel(service: service))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Chips
                filterChipsView

                // Contenido principal con estados
                mainContent
            }
            .navigationTitle("TV Guide")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if vm.isUsingCache {
                        HStack(spacing: 4) {
                            Image(systemName: "wifi.exclamationmark")
                                .foregroundColor(.orange)
                            Text("Offline")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .task {
            await vm.load()
        }
    }

    // MARK: - Filter Chips

    @ViewBuilder
    private var filterChipsView: some View {
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
        .visible(!vm.isLoading)
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        // Estado: Cargando (sin datos previos)
        if vm.isLoading && vm.programs.isEmpty {
            SkeletonLoadingView()
        }
        // Estado: Error
        else if let error = vm.error, vm.programs.isEmpty {
            EmptyStateView(error: error) {
                vm.retry()
            }
        }
        // Estado: Sin resultados
        else if vm.filteredPrograms.isEmpty {
            EmptyStateView(onRetry: {}) {
                vm.clearFilters()
                vm.clearSearch()
            }
        }
        // Estado: Lista normal
        else {
            programsList
        }
    }

    // MARK: - Programs List

    @ViewBuilder
    private var programsList: some View {
        List(vm.filteredPrograms) { program in
            NavigationLink(destination: ProgramDetailView(program: program)) {
                ProgramRow(program: program)
            }
            .onAppear {
                // Paginación opcional cuando se acerca al final
                // if program.id == vm.filteredPrograms.last?.id {
                //     Task { await vm.loadMore() }
                // }
            }
        }
        .listStyle(.plain)
        .searchable(
            text: $vm.searchText,
            prompt: "Buscar programas o episodios...",
            suggestions: {
                if !vm.searchText.isEmpty {
                    SuggestionsView(searchText: vm.searchText, onSelect: { suggestion in
                        vm.searchText = suggestion
                    })
                }
            }
        )
        .disabled(vm.isLoading)
        .overlay {
            // Loading overlay cuando hay datos previos
            if vm.isLoading && !vm.programs.isEmpty {
                loadingOverlay
            }
        }
    }

    // MARK: - Loading Overlay

    @ViewBuilder
    private var loadingOverlay: some View {
        ZStack {
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)

                Text("Actualizando...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.3))
    }
}

// MARK: - Program Row

struct ProgramRow: View {
    let program: TVProgram

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Imagen del show
            programImage

            // Información del programa
            programInfo
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var programImage: some View {
        Group {
            if let imageURL = program.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderImage
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }
        }
        .frame(width: 80, height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private var placeholderImage: some View {
        ZStack {
            Color.gray.opacity(0.2)
            Image(systemName: "photo")
                .foregroundColor(.gray)
                .font(.title3)
        }
    }

    @ViewBuilder
    private var programInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Show name
            Text(program.showName)
                .font(.headline)

            // Episode name
            Text(program.name)
                .font(.subheadline)
                .foregroundColor(.gray)

            // Badges
            badgesFlow

            // Fecha y hora
            dateTimeInfo

            // Resumen
            if let summary = program.summary, !summary.isEmpty {
                Text(summary.stripHTML())
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
        }
    }

    @ViewBuilder
    private var badgesFlow: some View {
        FlowLayout(spacing: 4) {
            // Season/Episode badge
            if let season = program.season, let number = program.number {
                Text("S\(season)E\(number)")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(Capsule())
            }

            // Type badge
            if let type = program.type, !type.isEmpty {
                Text(type.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.2))
                    .clipShape(Capsule())
            }

            // Rating badge
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

            // Network badge
            if let network = program.networkName {
                Text(network)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.purple.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
    }

    @ViewBuilder
    private var dateTimeInfo: some View {
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
    }
}

// MARK: - Suggestions View

struct SuggestionsView: View {
    let searchText: String
    let onSelect: (String) -> Void

    var body: some View {
        ForEach(["Show", "Episode", "Network", "All"], id: \.self) { suggestion in
            Button {
                onSelect(searchText + " " + suggestion)
            } label: {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Buscar en \(suggestion)")
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Filter Chip

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
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

// MARK: - FlowLayout

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

// MARK: - Extensions

extension View {
    @ViewBuilder
    func visible(_ condition: Bool) -> some View {
        if condition {
            self
        }
    }
}

extension Color {
    static var systemGroupedBackground: Color {
        Color(.systemGroupedBackground)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
