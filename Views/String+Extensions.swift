//
//  String+Extensions.swift
//  Guía TV
//
//  Created by Claudio Cataldo on 20-06-26.
//

import Foundation

extension String {
    /// Elimina etiquetas HTML y entidades HTML del texto
    func stripHTML() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Convierte código de país (US, CL, MX) a emoji de bandera
    func flagEmoji() -> String {
        let base: UInt32 = 127397
        var usv = String.UnicodeScalarView()
        for c in self.uppercased() {
            if let scalar = c.unicodeScalars.first {
                if let flagScalar = UnicodeScalar(base + scalar.value) {
                    usv.append(flagScalar)
                }
            }
        }
        return String(usv)
    }
}
