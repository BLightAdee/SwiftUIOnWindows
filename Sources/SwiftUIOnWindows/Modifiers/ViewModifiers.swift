// ViewModifiers.swift - Core view modifier infrastructure
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

// MARK: - ViewModifier Protocol

public protocol ViewModifier {
    associatedtype Body: View
    typealias Content = _ViewModifierContent
    @ViewBuilder func body(content: Content) -> Body
}

public struct _ViewModifierContent: View {
    public typealias Body = Never
    public var body: Never { fatalError("_ViewModifierContent uses custom rendering") }
}

// MARK: - ModifiedContent

public struct ModifiedContent<Content: View, Modifier: ViewModifier>: View {
    public typealias Body = Never
    public let content: Content
    public let modifier: Modifier

    public init(content: Content, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }

    public var body: Never { fatalError("ModifiedContent uses custom rendering") }
}

// MARK: - Core View Extension Modifiers

extension View {
    public func modifier<T: ViewModifier>(_ modifier: T) -> ModifiedContent<Self, T> {
        ModifiedContent(content: self, modifier: modifier)
    }

    // MARK: - Padding

    public func padding(_ insets: EdgeInsets) -> some View {
        ModifiedContent(content: self, modifier: PaddingModifier(insets: insets))
    }

    public func padding(_ edges: Edge.Set = .all, _ length: CGFloat = 8) -> some View {
        let insets = EdgeInsets(
            top: edges.contains(.top) ? length : 0,
            leading: edges.contains(.leading) ? length : 0,
            bottom: edges.contains(.bottom) ? length : 0,
            trailing: edges.contains(.trailing) ? length : 0
        )
        return ModifiedContent(content: self, modifier: PaddingModifier(insets: insets))
    }

    public func padding(_ length: CGFloat) -> some View {
        return self.padding(.all, length)
    }

    // MARK: - Frame

    public func frame(width: CGFloat? = nil, height: CGFloat? = nil,
                      alignment: Alignment = .center) -> some View {
        ModifiedContent(content: self, modifier: FrameModifier(
            width: width, height: height, alignment: alignment))
    }

    public func frame(minWidth: CGFloat? = nil, idealWidth: CGFloat? = nil,
                      maxWidth: CGFloat? = nil, minHeight: CGFloat? = nil,
                      idealHeight: CGFloat? = nil, maxHeight: CGFloat? = nil,
                      alignment: Alignment = .center) -> some View {
        ModifiedContent(content: self, modifier: FlexibleFrameModifier(
            minWidth: minWidth, idealWidth: idealWidth, maxWidth: maxWidth,
            minHeight: minHeight, idealHeight: idealHeight, maxHeight: maxHeight,
            alignment: alignment))
    }

    // MARK: - Background and Overlay

    public func background<V: View>(_ background: V, alignment: Alignment = .center) -> some View {
        ModifiedContent(content: self, modifier: BackgroundModifier(background: AnyView(background)))
    }

    public func background(_ color: Color) -> some View {
        ModifiedContent(content: self, modifier: BackgroundModifier(background: AnyView(color)))
    }

    public func overlay<V: View>(_ overlay: V, alignment: Alignment = .center) -> some View {
        ModifiedContent(content: self, modifier: OverlayModifier(overlay: AnyView(overlay)))
    }

    // MARK: - Foreground

    public func foregroundColor(_ color: Color?) -> some View {
        ModifiedContent(content: self, modifier: ForegroundColorModifier(color: color))
    }

    public func foregroundStyle(_ color: Color) -> some View {
        ModifiedContent(content: self, modifier: ForegroundColorModifier(color: color))
    }

    // MARK: - Font

    public func font(_ font: Font?) -> some View {
        ModifiedContent(content: self, modifier: FontModifier(font: font))
    }

    // MARK: - Corner Radius

    public func cornerRadius(_ radius: CGFloat) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusModifier(radius: radius))
    }

    // MARK: - Border

    public func border(_ color: Color, width: CGFloat = 1) -> some View {
        ModifiedContent(content: self, modifier: BorderModifier(color: color, width: width))
    }

    // MARK: - Shadow

    public func shadow(color: Color = Color(white: 0, opacity: 0.33),
                       radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) -> some View {
        ModifiedContent(content: self, modifier: ShadowModifier(
            color: color, radius: radius, x: x, y: y))
    }

    // MARK: - Opacity

    public func opacity(_ opacity: Double) -> some View {
        ModifiedContent(content: self, modifier: OpacityModifier(opacity: opacity))
    }

    // MARK: - Hidden

    public func hidden() -> some View {
        ModifiedContent(content: self, modifier: HiddenModifier())
    }

    // MARK: - Disabled

    public func disabled(_ disabled: Bool) -> some View {
        ModifiedContent(content: self, modifier: DisabledModifier(isDisabled: disabled))
    }

    // MARK: - Clip Shape

    public func clipShape<S: Shape>(_ shape: S) -> some View {
        ModifiedContent(content: self, modifier: ClipShapeModifier(shape: AnyShape(shape)))
    }

    // MARK: - Navigation Title

    public func navigationTitle(_ title: String) -> some View {
        ModifiedContent(content: self, modifier: NavigationTitleModifier(title: title))
    }

    // MARK: - Tab Item

    public func tabItem<V: View>(@ViewBuilder _ label: () -> V) -> some View {
        ModifiedContent(content: self, modifier: TabItemModifier())
    }

    // MARK: - Tag

    public func tag<V: Hashable>(_ tag: V) -> some View {
        ModifiedContent(content: self, modifier: TagModifier(tag: AnyHashable(tag)))
    }

    // MARK: - Rotation

    public func rotationEffect(_ angle: Angle) -> some View {
        ModifiedContent(content: self, modifier: RotationModifier(angle: angle))
    }

    // MARK: - Scale

    public func scaleEffect(_ scale: CGFloat) -> some View {
        ModifiedContent(content: self, modifier: ScaleModifier(x: scale, y: scale))
    }

    public func scaleEffect(x: CGFloat = 1, y: CGFloat = 1) -> some View {
        ModifiedContent(content: self, modifier: ScaleModifier(x: x, y: y))
    }

    // MARK: - Offset

    public func offset(x: CGFloat = 0, y: CGFloat = 0) -> some View {
        ModifiedContent(content: self, modifier: OffsetModifier(x: x, y: y))
    }

    // MARK: - Environment Object

    public func environmentObject<T: ObservableObject>(_ object: T) -> some View {
        EnvironmentStorage.shared.set(object)
        return ModifiedContent(content: self, modifier: EnvironmentObjectModifier())
    }

    // MARK: - On Appear / Disappear

    public func onAppear(perform action: (() -> Void)? = nil) -> some View {
        ModifiedContent(content: self, modifier: OnAppearModifier(action: action))
    }

    public func onDisappear(perform action: (() -> Void)? = nil) -> some View {
        ModifiedContent(content: self, modifier: OnDisappearModifier(action: action))
    }

    // MARK: - Aspect Ratio

    public func aspectRatio(_ ratio: CGFloat? = nil,
                            contentMode: ContentMode) -> some View {
        ModifiedContent(content: self, modifier: AspectRatioModifier(
            ratio: ratio, contentMode: contentMode))
    }

    public func scaledToFit() -> some View {
        aspectRatio(contentMode: .fit)
    }

    public func scaledToFill() -> some View {
        aspectRatio(contentMode: .fill)
    }

    // MARK: - Multiline Text Alignment

    public func multilineTextAlignment(_ alignment: TextAlignment) -> some View {
        ModifiedContent(content: self, modifier: MultilineTextAlignmentModifier(alignment: alignment))
    }

    // MARK: - Line Limit

    public func lineLimit(_ number: Int?) -> some View {
        ModifiedContent(content: self, modifier: LineLimitModifier(limit: number))
    }

    // MARK: - Minimum Scale Factor

    public func minimumScaleFactor(_ factor: CGFloat) -> some View {
        ModifiedContent(content: self, modifier: MinimumScaleFactorModifier(factor: factor))
    }
}

public enum ContentMode: Sendable { case fit, fill }

// MARK: - Modifier Implementations

internal struct PaddingModifier: ViewModifier {
    let insets: EdgeInsets
    func body(content: Content) -> some View { content }
}

internal struct FrameModifier: ViewModifier {
    let width: CGFloat?; let height: CGFloat?; let alignment: Alignment
    func body(content: Content) -> some View { content }
}

internal struct FlexibleFrameModifier: ViewModifier {
    let minWidth: CGFloat?; let idealWidth: CGFloat?; let maxWidth: CGFloat?
    let minHeight: CGFloat?; let idealHeight: CGFloat?; let maxHeight: CGFloat?
    let alignment: Alignment
    func body(content: Content) -> some View { content }
}

internal struct BackgroundModifier: ViewModifier {
    let background: AnyView
    func body(content: Content) -> some View { content }
}

internal struct OverlayModifier: ViewModifier {
    let overlay: AnyView
    func body(content: Content) -> some View { content }
}

internal struct ForegroundColorModifier: ViewModifier {
    let color: Color?
    func body(content: Content) -> some View { content }
}

internal struct FontModifier: ViewModifier {
    let font: Font?
    func body(content: Content) -> some View { content }
}

internal struct CornerRadiusModifier: ViewModifier {
    let radius: CGFloat
    func body(content: Content) -> some View { content }
}

internal struct BorderModifier: ViewModifier {
    let color: Color; let width: CGFloat
    func body(content: Content) -> some View { content }
}

internal struct ShadowModifier: ViewModifier {
    let color: Color; let radius: CGFloat; let x: CGFloat; let y: CGFloat
    func body(content: Content) -> some View { content }
}

internal struct OpacityModifier: ViewModifier {
    let opacity: Double
    func body(content: Content) -> some View { content }
}

internal struct HiddenModifier: ViewModifier {
    func body(content: Content) -> some View { content }
}

internal struct DisabledModifier: ViewModifier {
    let isDisabled: Bool
    func body(content: Content) -> some View { content }
}

internal struct ClipShapeModifier: ViewModifier {
    let shape: AnyShape
    func body(content: Content) -> some View { content }
}

internal struct NavigationTitleModifier: ViewModifier {
    let title: String
    func body(content: Content) -> some View { content }
}

internal struct TabItemModifier: ViewModifier {
    func body(content: Content) -> some View { content }
}

internal struct TagModifier: ViewModifier {
    let tag: AnyHashable
    func body(content: Content) -> some View { content }
}

internal struct RotationModifier: ViewModifier {
    let angle: Angle
    func body(content: Content) -> some View { content }
}

internal struct ScaleModifier: ViewModifier {
    let x: CGFloat; let y: CGFloat
    func body(content: Content) -> some View { content }
}

internal struct OffsetModifier: ViewModifier {
    let x: CGFloat; let y: CGFloat
    func body(content: Content) -> some View { content }
}

internal struct EnvironmentObjectModifier: ViewModifier {
    func body(content: Content) -> some View { content }
}

internal struct OnAppearModifier: ViewModifier {
    let action: (() -> Void)?
    func body(content: Content) -> some View { content }
}

internal struct OnDisappearModifier: ViewModifier {
    let action: (() -> Void)?
    func body(content: Content) -> some View { content }
}

internal struct AspectRatioModifier: ViewModifier {
    let ratio: CGFloat?; let contentMode: ContentMode
    func body(content: Content) -> some View { content }
}

internal struct MultilineTextAlignmentModifier: ViewModifier {
    let alignment: TextAlignment
    func body(content: Content) -> some View { content }
}

internal struct LineLimitModifier: ViewModifier {
    let limit: Int?
    func body(content: Content) -> some View { content }
}

internal struct MinimumScaleFactorModifier: ViewModifier {
    let factor: CGFloat
    func body(content: Content) -> some View { content }
}
