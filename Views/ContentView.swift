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
            List(vm.programs) { program in
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

                        HStack(spacing: 6) {
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
                        }

                        HStack {
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
                            Text(summary)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("TV Guide")
        }
        .task {
            await vm.load()
        }
    }
}
