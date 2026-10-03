import Foundation

/// Où trouver la page des presets : copie embarquée dans l'application, copie téléchargée
/// depuis GitHub, et la règle qui choisit entre les deux.
enum PresetPage {
    /// `index.html` du dépôt public : la source de vérité, mise à jour à chaque push sur `main`.
    static let remoteURL = URL(string: "https://raw.githubusercontent.com/mdany75/presets-x-h2s/main/index.html")!

    /// Copie embarquée au moment de la compilation (toujours disponible, même hors ligne).
    static var bundledURL: URL? {
        Bundle.main.url(forResource: "index", withExtension: "html")
    }

    /// Dernière copie téléchargée depuis GitHub.
    static var downloadedURL: URL {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return support.appendingPathComponent("Presets X-H2S", isDirectory: true)
            .appendingPathComponent("index.html")
    }

    /// Texte de `<div class="ver">Version 1.1 · 3 octobre 2026</div>`, pour l'affichage seulement :
    /// le numéro de version ne change plus à chaque fiche, il ne sert donc pas à comparer deux copies.
    static func versionLabel(of html: String) -> String? {
        guard let open = html.range(of: #"class="ver">"#),
              let close = html.range(of: "<", range: open.upperBound..<html.endIndex) else {
            return nil
        }
        let label = html[open.upperBound..<close.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
        return label.isEmpty ? nil : label
    }

    /// Une page téléchargée n'est acceptée que si elle ressemble à la bibliothèque
    /// (une page d'erreur ou un fichier tronqué ne remplace jamais la copie locale).
    static func isValid(_ html: String) -> Bool {
        versionLabel(of: html) != nil && html.contains("var DATA = [") && html.contains("</script>")
    }

    static func read(_ url: URL?) -> String? {
        guard let url else { return nil }
        return try? String(contentsOf: url, encoding: .utf8)
    }

    private static func modificationDate(_ url: URL?) -> Date {
        guard let url, let values = try? url.resourceValues(forKeys: [.contentModificationDateKey]) else {
            return .distantPast
        }
        return values.contentModificationDate ?? .distantPast
    }

    /// Page à afficher : la copie téléchargée, sauf si l'application a été construite après le
    /// dernier téléchargement (sa copie embarquée est alors la plus récente des deux).
    static func localURL() -> URL? {
        if let downloaded = read(downloadedURL), isValid(downloaded),
           modificationDate(downloadedURL) >= modificationDate(bundledURL) {
            return downloadedURL
        }
        return bundledURL
    }

    static func saveDownloaded(_ html: String) throws {
        let directory = downloadedURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try html.write(to: downloadedURL, atomically: true, encoding: .utf8)
    }
}
