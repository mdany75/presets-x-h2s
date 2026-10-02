// make_icon.swift — dessine l'icône de « Presets X-H2S » : une molette de modes calée sur C1.
//
// Usage : make_icon <dossier .iconset de sortie>
//
// Écrit les dix PNG attendus par `iconutil -c icns`. Le dessin est vectoriel et refait à
// chaque taille sur la grille macOS : canevas de 1024, tuile arrondie de 824, marge de 100.

import AppKit
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!

func rgb(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(colorSpace: sRGB, components: [CGFloat((hex >> 16) & 0xFF) / 255,
                                           CGFloat((hex >> 8) & 0xFF) / 255,
                                           CGFloat(hex & 0xFF) / 255, alpha])!
}

func gradient(_ colors: [CGColor]) -> CGGradient {
    CGGradient(colorsSpace: sRGB, colors: colors as CFArray, locations: nil)!
}

/// Dessine l'icône dans un repère de 1024 × 1024 (origine en bas à gauche).
func draw(in ctx: CGContext) {
    let tile = CGRect(x: 100, y: 100, width: 824, height: 824)
    let tilePath = CGPath(roundedRect: tile, cornerWidth: 185, cornerHeight: 185, transform: nil)
    let center = CGPoint(x: 512, y: 500)

    // Tuile : les couleurs sombres de la page.
    ctx.saveGState()
    ctx.addPath(tilePath)
    ctx.clip()
    ctx.drawLinearGradient(gradient([rgb(0x2a2520), rgb(0x121110)]),
                           start: CGPoint(x: 512, y: 924), end: CGPoint(x: 512, y: 100), options: [])
    ctx.restoreGState()

    // Molette : couronne crantée.
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -14), blur: 36, color: rgb(0x000000, 0.55))
    ctx.setFillColor(rgb(0x3a352e))
    ctx.fillEllipse(in: CGRect(x: center.x - 318, y: center.y - 318, width: 636, height: 636))
    ctx.restoreGState()

    ctx.saveGState()
    ctx.setStrokeColor(rgb(0x121110, 0.8))
    ctx.setLineWidth(11)
    ctx.setLineCap(.butt)
    let notches = 44
    for i in 0..<notches {
        let angle = CGFloat(i) / CGFloat(notches) * 2 * .pi
        ctx.move(to: CGPoint(x: center.x + cos(angle) * 276, y: center.y + sin(angle) * 276))
        ctx.addLine(to: CGPoint(x: center.x + cos(angle) * 320, y: center.y + sin(angle) * 320))
    }
    ctx.strokePath()
    ctx.restoreGState()

    // Dessus de la molette.
    let top = CGRect(x: center.x - 262, y: center.y - 262, width: 524, height: 524)
    ctx.saveGState()
    ctx.addEllipse(in: top)
    ctx.clip()
    ctx.drawLinearGradient(gradient([rgb(0x2e2a24), rgb(0x1a1917)]),
                           start: CGPoint(x: 512, y: top.maxY), end: CGPoint(x: 512, y: top.minY), options: [])
    ctx.restoreGState()
    ctx.setStrokeColor(rgb(0x4a443b))
    ctx.setLineWidth(5)
    ctx.strokeEllipse(in: top.insetBy(dx: 2.5, dy: 2.5))

    // « C1 » en ambre.
    let font = NSFont.systemFont(ofSize: 268, weight: .heavy)
    let rounded = font.fontDescriptor.withDesign(.rounded).flatMap { NSFont(descriptor: $0, size: 268) } ?? font
    let text = NSAttributedString(string: "C1", attributes: [
        .font: rounded,
        .foregroundColor: NSColor(cgColor: rgb(0xe8973c))!,
        .kern: -6,
    ])
    let line = CTLineCreateWithAttributedString(text)
    let bounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
    ctx.textPosition = CGPoint(x: center.x - bounds.midX, y: center.y - bounds.midY)
    CTLineDraw(line, ctx)

    // Repère fixe au-dessus de la molette.
    ctx.setFillColor(rgb(0x4fd1c0))
    ctx.move(to: CGPoint(x: 512, y: 828))
    ctx.addLine(to: CGPoint(x: 478, y: 880))
    ctx.addLine(to: CGPoint(x: 546, y: 880))
    ctx.closePath()
    ctx.fillPath()
}

func writePNG(pixels: Int, to url: URL) {
    guard let ctx = CGContext(data: nil, width: pixels, height: pixels, bitsPerComponent: 8, bytesPerRow: 0,
                              space: sRGB, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
        fatalError("contexte graphique indisponible")
    }
    ctx.scaleBy(x: CGFloat(pixels) / 1024, y: CGFloat(pixels) / 1024)
    draw(in: ctx)
    guard let image = ctx.makeImage(),
          let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        fatalError("écriture impossible : \(url.path)")
    }
    CGImageDestinationAddImage(dest, image, nil)
    guard CGImageDestinationFinalize(dest) else { fatalError("écriture impossible : \(url.path)") }
}

guard CommandLine.arguments.count == 2 else {
    FileHandle.standardError.write("usage : make_icon <dossier .iconset>\n".data(using: .utf8)!)
    exit(1)
}
let output = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

for size in [16, 32, 128, 256, 512] {
    writePNG(pixels: size, to: output.appendingPathComponent("icon_\(size)x\(size).png"))
    writePNG(pixels: size * 2, to: output.appendingPathComponent("icon_\(size)x\(size)@2x.png"))
}
