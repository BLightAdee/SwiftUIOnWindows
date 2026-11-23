// Win32Renderer.swift - Win32 GDI rendering backend
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation
#if canImport(WinSDK)
import WinSDK
#endif

/// Renders RenderNodes to a Win32 window using GDI.
public final class Win32Renderer: @unchecked Sendable {
    public static let shared = Win32Renderer()

    private init() {}

    #if canImport(WinSDK)
    /// Render all nodes to the given HDC (device context).
    public func render(nodes: [RenderNode], to hdc: HDC?, in rect: RECT) {
        guard let hdc = hdc else { return }

        // Clear background with macOS-like light gray
        let bgBrush = CreateSolidBrush(colorRef(Color(red: 0.933, green: 0.933, blue: 0.933)))
        var fillRect = rect
        FillRect(hdc, &fillRect, bgBrush)
        DeleteObject(bgBrush)

        for node in nodes {
            renderNode(node, to: hdc)
        }
    }

    private func renderNode(_ node: RenderNode, to hdc: HDC?) {
        guard let hdc = hdc else { return }

        switch node {
        case .text(let str, let font, let color, let rect):
            renderText(str, font: font, color: color, rect: rect, hdc: hdc)

        case .rect(let color, let rect, let cornerRadius):
            renderRect(color: color, rect: rect, cornerRadius: cornerRadius, hdc: hdc)

        case .border(let color, let rect, let cornerRadius, let width):
            renderBorder(color: color, rect: rect, cornerRadius: cornerRadius,
                         width: width, hdc: hdc)

        case .group(let children):
            for child in children { renderNode(child, to: hdc) }

        case .empty:
            break
        }
    }

    private func renderText(_ text: String, font: Font, color: Color,
                            rect: CGRect, hdc: HDC) {
        // Create font
        let fontHeight = -Int32(font.size * 96.0 / 72.0)
        let weight = Int32(font.weight.rawValue)
        let italic: UInt32 = font.isItalic ? 1 : 0

        let fontName = font.win32FontName
        let hFont = fontName.withCString(encodedAs: UTF16.self) { namePtr in
            CreateFontW(
                fontHeight, 0, 0, 0, weight, italic, 0, 0,
                UInt32(DEFAULT_CHARSET),
                UInt32(OUT_DEFAULT_PRECIS),
                UInt32(CLIP_DEFAULT_PRECIS),
                UInt32(CLEARTYPE_QUALITY),
                UInt32(DEFAULT_PITCH) | UInt32(FF_DONTCARE),
                namePtr
            )
        }

        let oldFont = SelectObject(hdc, hFont)
        SetTextColor(hdc, colorRef(color))
        SetBkMode(hdc, Int32(TRANSPARENT))

        var drawRect = RECT(
            left: Int32(rect.origin.x),
            top: Int32(rect.origin.y),
            right: Int32(rect.origin.x + rect.size.width),
            bottom: Int32(rect.origin.y + rect.size.height)
        )

        let flags = UInt32(DT_LEFT) | UInt32(DT_TOP) | UInt32(DT_WORDBREAK) | UInt32(DT_NOPREFIX)

        text.withCString(encodedAs: UTF16.self) { textPtr in
            DrawTextW(hdc, textPtr, Int32(text.utf16.count), &drawRect, flags)
        }

        SelectObject(hdc, oldFont)
        if let hFont = hFont { DeleteObject(hFont) }
    }

    private func renderRect(color: Color, rect: CGRect, cornerRadius: CGFloat, hdc: HDC) {
        let brush = CreateSolidBrush(colorRef(color))
        let oldBrush = SelectObject(hdc, brush)
        let nullPen = GetStockObject(Int32(NULL_PEN))
        let oldPen = SelectObject(hdc, nullPen)

        if cornerRadius > 0 {
            let cr = Int32(cornerRadius * 2)
            RoundRect(hdc,
                      Int32(rect.origin.x), Int32(rect.origin.y),
                      Int32(rect.origin.x + rect.size.width),
                      Int32(rect.origin.y + rect.size.height),
                      cr, cr)
        } else {
            var r = RECT(
                left: Int32(rect.origin.x),
                top: Int32(rect.origin.y),
                right: Int32(rect.origin.x + rect.size.width),
                bottom: Int32(rect.origin.y + rect.size.height)
            )
            FillRect(hdc, &r, brush)
        }

        SelectObject(hdc, oldPen)
        SelectObject(hdc, oldBrush)
        DeleteObject(brush)
    }

    private func renderBorder(color: Color, rect: CGRect, cornerRadius: CGFloat,
                              width: CGFloat, hdc: HDC) {
        let pen = CreatePen(Int32(PS_SOLID), Int32(width), colorRef(color))
        let oldPen = SelectObject(hdc, pen)
        let nullBrush = GetStockObject(Int32(NULL_BRUSH))
        let oldBrush = SelectObject(hdc, nullBrush)

        if cornerRadius > 0 {
            let cr = Int32(cornerRadius * 2)
            RoundRect(hdc,
                      Int32(rect.origin.x), Int32(rect.origin.y),
                      Int32(rect.origin.x + rect.size.width),
                      Int32(rect.origin.y + rect.size.height),
                      cr, cr)
        } else {
            let r = RECT(
                left: Int32(rect.origin.x),
                top: Int32(rect.origin.y),
                right: Int32(rect.origin.x + rect.size.width),
                bottom: Int32(rect.origin.y + rect.size.height)
            )
            _ = WinSDK.Rectangle(hdc, r.left, r.top, r.right, r.bottom)
        }

        SelectObject(hdc, oldBrush)
        SelectObject(hdc, oldPen)
        DeleteObject(pen)
    }

    private func colorRef(_ color: Color) -> COLORREF {
        let r = UInt8(max(0, min(1, color.red)) * 255)
        let g = UInt8(max(0, min(1, color.green)) * 255)
        let b = UInt8(max(0, min(1, color.blue)) * 255)
        return COLORREF(UInt32(r) | (UInt32(g) << 8) | (UInt32(b) << 16))
    }
    #else
    // Stub for non-Windows platforms
    public func render(nodes: [RenderNode], to context: Any?, in rect: Any) {
        print("Win32Renderer: Not running on Windows, skipping render")
        for node in nodes {
            switch node {
            case .text(let str, _, _, _): print("  TEXT: \(str)")
            case .rect(_, let r, _): print("  RECT: \(r)")
            case .border(_, let r, _, _): print("  BORDER: \(r)")
            case .group(let children): print("  GROUP: \(children.count) children")
            case .empty: break
            }
        }
    }
    #endif
}
