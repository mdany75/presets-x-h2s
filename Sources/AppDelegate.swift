import AppKit
import WebKit

final class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    private var window: NSWindow!
    private var webView: WKWebView!
    private var displayedURL: URL?
    private var updateInProgress = false

    private let zoomKey = "pageZoom"
    private let debug = ProcessInfo.processInfo.environment["PRESETS_DEBUG"] != nil
    /// Diagnostic : chemin d'un PDF dans lequel imprimer quelques fiches au lancement, sans dialogue.
    private let printTestPath = ProcessInfo.processInfo.environment["PRESETS_PRINT_TEST"]
    /// Diagnostic : fenêtre de taille fixe avec deux fiches sélectionnées, pour la capture du README.
    private let screenshotMode = ProcessInfo.processInfo.environment["PRESETS_SCREENSHOT"] != nil

    // MARK: - Cycle de vie

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.mainMenu = buildMenu()

        // La sélection et la mise en page d'impression sont injectées dans la page, qui reste
        // identique à celle du dépôt.
        let configuration = WKWebViewConfiguration()
        if let url = Bundle.main.url(forResource: "selection", withExtension: "js"),
           let source = try? String(contentsOf: url, encoding: .utf8) {
            configuration.userContentController.addUserScript(
                WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        }
        configuration.userContentController.add(self, name: "presets")

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.allowsMagnification = true
        // Évite l'éclair blanc avant le premier rendu en apparence sombre.
        webView.underPageBackgroundColor = .windowBackgroundColor
        let savedZoom = UserDefaults.standard.double(forKey: zoomKey)
        if savedZoom > 0 { webView.pageZoom = savedZoom }

        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1180, height: 860),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered, defer: false)
        window.title = "Presets X-H2S"
        window.minSize = NSSize(width: 420, height: 480)
        window.contentView = webView
        window.center()
        if screenshotMode {
            window.setContentSize(NSSize(width: 1280, height: 860))
            window.center()
        } else {
            window.setFrameAutosaveName("PresetsWindow")
        }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        loadLocalPage()
        checkForUpdate(userInitiated: false)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    // MARK: - Page

    private func loadLocalPage() {
        guard let url = PresetPage.localURL() else {
            webView.loadHTMLString("<p style='font:15px -apple-system;padding:40px'>Page des presets introuvable dans l'application.</p>", baseURL: nil)
            return
        }
        displayedURL = url
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }

    /// Compare la page affichée à celle du dépôt GitHub et la remplace si le dépôt est plus récent.
    /// Au lancement, la vérification est silencieuse ; depuis le menu, le résultat est annoncé.
    private func checkForUpdate(userInitiated: Bool) {
        guard !updateInProgress else { return }
        updateInProgress = true

        var request = URLRequest(url: PresetPage.remoteURL, cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 15)
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.updateInProgress = false
                let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                guard error == nil, status == 200, let data,
                      let remote = String(data: data, encoding: .utf8), PresetPage.isValid(remote) else {
                    if self.debug { self.trace("mise à jour : échec (HTTP \(status)) \(error?.localizedDescription ?? "")") }
                    if userInitiated {
                        self.inform("Mise à jour impossible",
                                    error?.localizedDescription ?? "GitHub n'a pas renvoyé une page de presets valide (HTTP \(status)).")
                    }
                    return
                }
                self.apply(remote: remote, userInitiated: userInitiated)
            }
        }.resume()
    }

    /// Le dépôt GitHub fait foi : toute page valide différente de celle affichée la remplace.
    private func apply(remote: String, userInitiated: Bool) {
        let current = PresetPage.read(displayedURL) ?? ""
        let label = PresetPage.versionLabel(of: remote) ?? "?"

        if remote == current {
            if debug { trace("mise à jour : déjà à jour (\(label))") }
            if userInitiated { inform("Presets à jour", "\(label), identique au dépôt GitHub.") }
            return
        }
        do {
            try PresetPage.saveDownloaded(remote)
        } catch {
            if userInitiated { inform("Mise à jour impossible", error.localizedDescription) }
            return
        }
        if debug { trace("mise à jour : \(PresetPage.versionLabel(of: current) ?? "?") → \(label)") }
        loadLocalPage()
        if userInitiated { inform("Presets mis à jour", "\(label), téléchargée depuis GitHub.") }
    }

    private func inform(_ title: String, _ text: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.beginSheetModal(for: window)
    }

    /// Journal de diagnostic (PRESETS_DEBUG=1), écrit sans tampon sur la sortie d'erreur.
    private func trace(_ message: String) {
        FileHandle.standardError.write((message + "\n").data(using: .utf8)!)
    }

    // MARK: - WKNavigationDelegate

    /// Les liens externes s'ouvrent dans le navigateur par défaut ; la fenêtre ne quitte jamais la page.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url,
           url.scheme == "http" || url.scheme == "https" {
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let printTestPath { runPrintTest(to: printTestPath) }
        if screenshotMode {
            webView.evaluateJavaScript("""
                var picks = document.querySelectorAll('.pcard .xh-pick');
                picks[0].click(); picks[2].click();
                """)
        }
        guard debug else { return }
        let script = "document.querySelector('.ver').textContent + ' — ' + document.querySelectorAll('.pcard').length + ' fiches'"
        webView.evaluateJavaScript(script) { result, error in
            self.trace("page chargée : \(result ?? error?.localizedDescription ?? "?") (\(self.displayedURL?.path ?? "-"))")
        }
    }

    // MARK: - Impression

    /// Message envoyé par le bouton « Imprimer… » de la barre de sélection.
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.body as? String == "print" { printSelection(nil) }
    }

    @objc private func printSelection(_ sender: Any?) {
        webView.evaluateJavaScript("window.xhSelection ? xhSelection.prepare() : -1") { result, _ in
            let count = result as? Int ?? -1
            guard count > 0 else {
                self.inform("Aucune fiche sélectionnée",
                            "Clique sur la pastille en haut à droite des fiches à imprimer, ou choisis Fichier > Sélectionner les fiches affichées.")
                return
            }
            self.runPrintOperation(self.printInfo(), panels: true)
        }
    }

    @objc private func selectVisible(_ sender: Any?) {
        webView.evaluateJavaScript("window.xhSelection && xhSelection.selectVisible()")
    }

    @objc private func clearSelection(_ sender: Any?) {
        webView.evaluateJavaScript("window.xhSelection && xhSelection.clear()")
    }

    private func printInfo() -> NSPrintInfo {
        let info = NSPrintInfo.shared.copy() as! NSPrintInfo
        info.topMargin = 28
        info.bottomMargin = 28
        info.leftMargin = 34
        info.rightMargin = 34
        info.horizontalPagination = .fit
        info.verticalPagination = .automatic
        info.isHorizontallyCentered = false
        info.isVerticallyCentered = false
        return info
    }

    private func runPrintOperation(_ info: NSPrintInfo, panels: Bool) {
        let operation = webView.printOperation(with: info)
        operation.showsPrintPanel = panels
        operation.showsProgressPanel = panels
        operation.jobTitle = "Presets X-H2S"
        // Sans dimensions, la vue d'impression de WebKit produit des pages vides.
        operation.view?.frame = webView.bounds
        operation.runModal(for: window, delegate: self,
                           didRun: #selector(printOperationDidRun(_:success:contextInfo:)), contextInfo: nil)
    }

    @objc private func printOperationDidRun(_ operation: NSPrintOperation, success: Bool, contextInfo: UnsafeMutableRawPointer?) {
        guard printTestPath != nil else { return }
        trace("impression de test : \(success ? "terminée" : "échec")")
        NSApp.terminate(nil)
    }

    private func runPrintTest(to path: String) {
        let script = """
            Array.prototype.slice.call(document.querySelectorAll('.pcard'), 0, 8)
                .concat([document.querySelector('.card.bank')]).concat(Array.prototype.filter.call(document.querySelectorAll('.pcard h3'), function (h) { return /pluie/.test(h.textContent); }).map(function (h) { return h.parentNode; }))
                .forEach(function (c) { c.querySelector('.xh-pick').click(); });
            xhSelection.prepare()
            """
        webView.evaluateJavaScript(script) { result, error in
            self.trace("impression de test : \(result ?? error?.localizedDescription ?? "?") fiches")
            // Image de la fenêtre avec la sélection, pour contrôler les pastilles et la barre.
            self.webView.takeSnapshot(with: nil) { image, _ in
                if let tiff = image?.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff),
                   let png = bitmap.representation(using: .png, properties: [:]) {
                    try? png.write(to: URL(fileURLWithPath: path + ".png"))
                }
            }
            let info = self.printInfo()
            info.jobDisposition = .save
            info.dictionary()[NSPrintInfo.AttributeKey.jobSavingURL] = URL(fileURLWithPath: path)
            self.runPrintOperation(info, panels: false)
        }
    }

    // MARK: - Actions de menu

    @objc private func focusSearch(_ sender: Any?) {
        window.makeFirstResponder(webView)
        // La recherche est dans l'onglet Bibliothèque ; elle reste collée sous l'en-tête, sans défilement.
        webView.evaluateJavaScript("""
            if (window.xhShowTab) xhShowTab('bibliotheque');
            var s = document.getElementById('libsearch');
            if (s) { if (!window.xhShowTab) s.scrollIntoView({block: 'center'}); s.focus({preventScroll: true}); s.select(); }
            """)
    }

    @objc private func updateFromGitHub(_ sender: Any?) { checkForUpdate(userInitiated: true) }

    @objc private func zoomIn(_ sender: Any?) { setZoom(webView.pageZoom + 0.1) }
    @objc private func zoomOut(_ sender: Any?) { setZoom(webView.pageZoom - 0.1) }
    @objc private func zoomReset(_ sender: Any?) { setZoom(1) }

    private func setZoom(_ value: CGFloat) {
        let zoom = min(max(value, 0.5), 3)
        webView.pageZoom = zoom
        UserDefaults.standard.set(Double(zoom), forKey: zoomKey)
    }

    // MARK: - Menus

    private func buildMenu() -> NSMenu {
        let main = NSMenu()

        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "À propos de Presets X-H2S",
                        action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(item("Mettre à jour depuis GitHub", #selector(updateFromGitHub(_:)), "r"))
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Masquer Presets X-H2S", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        let hideOthers = appMenu.addItem(withTitle: "Masquer les autres",
                                         action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h")
        hideOthers.keyEquivalentModifierMask = [.command, .option]
        appMenu.addItem(withTitle: "Tout afficher", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Quitter Presets X-H2S", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        main.addItem(submenu(appMenu, title: ""))

        let file = NSMenu(title: "Fichier")
        file.addItem(item("Imprimer la sélection…", #selector(printSelection(_:)), "p"))
        file.addItem(.separator())
        let pickVisible = item("Sélectionner les fiches affichées", #selector(selectVisible(_:)), "a")
        pickVisible.keyEquivalentModifierMask = [.command, .shift]
        file.addItem(pickVisible)
        let unpick = item("Tout désélectionner", #selector(clearSelection(_:)), "d")
        unpick.keyEquivalentModifierMask = [.command, .shift]
        file.addItem(unpick)
        main.addItem(submenu(file, title: "Fichier"))

        let edit = NSMenu(title: "Édition")
        edit.addItem(withTitle: "Copier", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        edit.addItem(withTitle: "Coller", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        edit.addItem(withTitle: "Tout sélectionner", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        edit.addItem(.separator())
        edit.addItem(item("Rechercher un preset", #selector(focusSearch(_:)), "f"))
        main.addItem(submenu(edit, title: "Édition"))

        let view = NSMenu(title: "Présentation")
        view.addItem(item("Taille réelle", #selector(zoomReset(_:)), "0"))
        view.addItem(item("Agrandir", #selector(zoomIn(_:)), "+"))
        view.addItem(item("Réduire", #selector(zoomOut(_:)), "-"))
        view.addItem(.separator())
        let fullScreen = view.addItem(withTitle: "Plein écran", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f")
        fullScreen.keyEquivalentModifierMask = [.command, .control]
        main.addItem(submenu(view, title: "Présentation"))

        let windowMenu = NSMenu(title: "Fenêtre")
        windowMenu.addItem(withTitle: "Placer dans le Dock", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(withTitle: "Fermer", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        main.addItem(submenu(windowMenu, title: "Fenêtre"))
        NSApp.windowsMenu = windowMenu

        return main
    }

    private func item(_ title: String, _ action: Selector, _ key: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        return item
    }

    private func submenu(_ menu: NSMenu, title: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.submenu = menu
        return item
    }
}
