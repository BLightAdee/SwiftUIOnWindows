// ViewBuilder.swift - @resultBuilder for declarative View composition
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

@resultBuilder
public struct ViewBuilder {

    public static func buildExpression<Content: View>(_ content: Content) -> Content {
        return content
    }

    public static func buildBlock<Content: View>(_ content: Content) -> Content {
        return content
    }

    public static func buildBlock<C0: View, C1: View>(
        _ c0: C0, _ c1: C1
    ) -> TupleView<(C0, C1)> {
        return TupleView((c0, c1))
    }

    public static func buildBlock<C0: View, C1: View, C2: View>(
        _ c0: C0, _ c1: C1, _ c2: C2
    ) -> TupleView<(C0, C1, C2)> {
        return TupleView((c0, c1, c2))
    }

    public static func buildBlock<C0: View, C1: View, C2: View, C3: View>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3
    ) -> TupleView<(C0, C1, C2, C3)> {
        return TupleView((c0, c1, c2, c3))
    }

    public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4
    ) -> TupleView<(C0, C1, C2, C3, C4)> {
        return TupleView((c0, c1, c2, c3, c4))
    }

    public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5
    ) -> TupleView<(C0, C1, C2, C3, C4, C5)> {
        return TupleView((c0, c1, c2, c3, c4, c5))
    }

    public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6
    ) -> TupleView<(C0, C1, C2, C3, C4, C5, C6)> {
        return TupleView((c0, c1, c2, c3, c4, c5, c6))
    }

    public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7
    ) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7)> {
        return TupleView((c0, c1, c2, c3, c4, c5, c6, c7))
    }

    public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8
    ) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8)> {
        return TupleView((c0, c1, c2, c3, c4, c5, c6, c7, c8))
    }

    public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9
    ) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)> {
        return TupleView((c0, c1, c2, c3, c4, c5, c6, c7, c8, c9))
    }

    public static func buildOptional<Content: View>(_ content: Content?) -> Content? {
        return content
    }

    public static func buildEither<TrueContent: View, FalseContent: View>(
        first: TrueContent
    ) -> ConditionalContent<TrueContent, FalseContent> {
        return ConditionalContent(storage: .trueContent(first))
    }

    public static func buildEither<TrueContent: View, FalseContent: View>(
        second: FalseContent
    ) -> ConditionalContent<TrueContent, FalseContent> {
        return ConditionalContent(storage: .falseContent(second))
    }
}
