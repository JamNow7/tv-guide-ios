//
//  ProgramDetailView.swift
//  Guía TV
//
//  Created by Claudio Cataldo on 20-06-26.
//

import SwiftUI

  struct ProgramDetailView: View {
      let program: TVProgram

      var body: some View {
          ScrollView {
              VStack(alignment: .leading, spacing: 20) {
                  // Header con imagen
                  AsyncImage(url: URL(string: program.imageURL ?? "")) { phase in
                      switch phase {
                      case .success(let image):
                          image
                              .resizable()
                              .aspectRatio(contentMode: .fit)
                              .frame(maxHeight: 300)
                              .clipShape(RoundedRectangle(cornerRadius: 12))
                      case .empty, .failure:
                          Rectangle()
                              .fill(Color.gray.opacity(0.2))
                              .frame(height: 200)
                              .overlay(
                                  Image(systemName: "photo")
                                      .font(.largeTitle)
                                      .foregroundColor(.gray)
                              )
                              .clipShape(RoundedRectangle(cornerRadius: 12))
                      @unknown default:
                          EmptyView()
                      }
                  }
                  .frame(maxWidth: .infinity)
                  .padding()

                  // Información principal
                  VStack(alignment: .leading, spacing: 12) {
                      // Título del show
                      Text(program.showName)
                          .font(.largeTitle)
                          .fontWeight(.bold)

                      // Nombre del episodio
                      Text(program.name)
                          .font(.title2)
                          .foregroundColor(.secondary)

                      // Badges
                      HStack(spacing: 8) {
                          if let season = program.season, let number = program.number {
                              Label("S\(season)E\(number)", systemImage: "tv")
                                  .font(.caption)
                                  .padding(.horizontal, 10)
                                  .padding(.vertical, 5)
                                  .background(Color.blue.opacity(0.2))
                                  .clipShape(Capsule())
                          }

                          if let type = program.type {
                              Label(type.capitalized, systemImage: "film")
                                  .font(.caption)
                                  .padding(.horizontal, 10)
                                  .padding(.vertical, 5)
                                  .background(Color.green.opacity(0.2))
                                  .clipShape(Capsule())
                          }

                          if let runtime = program.runtime {
                              Label("\(runtime) min", systemImage: "clock")
                                  .font(.caption)
                                  .padding(.horizontal, 10)
                                  .padding(.vertical, 5)
                                  .background(Color.orange.opacity(0.2))
                                  .clipShape(Capsule())
                          }

                          if let rating = program.rating {
                              Label(String(format: "%.1f", rating), systemImage: "star.fill")
                                  .font(.caption)
                                  .padding(.horizontal, 10)
                                  .padding(.vertical, 5)
                                  .background(Color.yellow.opacity(0.2))
                                  .clipShape(Capsule())
                          }
                      }

                      Divider()

                      // Fecha y hora
                      HStack(spacing: 20) {
                          VStack(alignment: .leading, spacing: 4) {
                              Label("Fecha", systemImage: "calendar")
                                  .font(.caption)
                                  .foregroundColor(.secondary)
                              Text(program.airdate)
                                  .font(.headline)
                          }

                          VStack(alignment: .leading, spacing: 4) {
                              Label("Hora", systemImage: "clock")
                                  .font(.caption)
                                  .foregroundColor(.secondary)
                              Text(program.airtime)
                                  .font(.headline)
                          }

                          // Canal
                          if let network = program.networkName {
                              VStack(alignment: .leading, spacing: 4) {
                                  Label("Canal", systemImage: "tv")
                                      .font(.caption)
                                      .foregroundColor(.secondary)
                                  HStack(spacing: 6) {
                                      if let countryCode = program.countryCode {
                                          Text(countryCode.flagEmoji())
                                              .font(.title2)
                                      }
                                      Text(network)
                                          .font(.headline)
                                  }
                              }
                          }
                      }

                      Divider()

                      // Resumen
                      if let summary = program.summary, !summary.isEmpty {
                          VStack(alignment: .leading, spacing: 8) {
                              Label("Resumen", systemImage: "text.alignleft")
                                  .font(.headline)

                              Text(summary.stripHTML())
                                  .font(.body)
                                  .foregroundColor(.secondary)
                          }
                      }
                  }
                  .padding(.horizontal)

                  Spacer()
              }
          }
          .navigationTitle("Detalles")
          .navigationBarTitleDisplayMode(.inline)
      }
  }
