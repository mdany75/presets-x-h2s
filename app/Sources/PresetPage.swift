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

    /// Numéro lu dans `<div class="ver">Version N · date</div>`.
    static func version(of html: String) -> Int? {
        guard let range = html.range(of: #"class="ver">Version (\d+)"#, options: .regularExpression) else {
            return nil
        }
        return Int(html[range].filter(\.isNumber))
    }

    /// Une page téléchargée n'est acceptée que si elle ressemble à la bibliothèque
    /// (une page d'erreur ou un fichier tronqué ne remplace jamais la copie locale).
    static func isValid(_ html: String) -> Bool {
        version(of: html) != nil && html.contains("var DATA = [") && html.contains("</script>")
    }

    static func read(_ url: URL?) -> String? {
        guard let url else { return nil }
        return try? String(contentsOf: url, encoding: .utf8)
    }

    /// Page à afficher : la copie téléchargée si elle est au moins aussi récente que la copie
    /// embarquée, sinon la copie embarquée.
    static func localURL() -> URL? {
        let bundledVersion = read(bundledURL).flatMap(version(of:)) ?? 0
        if let downloaded = read(downloadedURL), isValid(downloaded),
           (version(of: downloaded) ?? 0) >= bundledVersion {
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
