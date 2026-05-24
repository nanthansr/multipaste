import SwiftUI
import AppKit

struct RadialHUDView: View {
    let clips: [Clip]
    let onSelect: (Clip) -> Void

    @State private var hoveredID: Int64? = nil

    private let radius: CGFloat = 160
    // The slot frame is FIXED at 110×110 regardless of hover state.
    // This keeps the SwiftUI hit area stable so .onHover never flickers.
    private let slotSize: CGFloat = 110

    var body: some View {
        ZStack {
            ForEach(Array(clips.enumerated()), id: \.element.id) { index, clip in
                let angle = (2 * Double.pi / Double(clips.count)) * Double(index) - Double.pi / 2
                let x = CGFloat(cos(angle)) * radius
                let y = CGFloat(-sin(angle)) * radius
                let isHovered = hoveredID == clip.id

                tileSlot(for: clip, isHovered: isHovered)
                    .offset(x: x, y: y)
                    .zIndex(isHovered ? 1 : 0)
            }
        }
        .frame(width: 600, height: 600)
        .background(Color.clear)
    }

    // Each slot is always 110×110. On hover, the CONTENT changes from
    // a compact thumbnail to an expanded preview - no scale, no floating card.
    @ViewBuilder
    private func tileSlot(for clip: Clip, isHovered: Bool) -> some View {
        ZStack {
            VisualEffectView(
                material: .hudWindow,
                blendingMode: .behindWindow
            )
            .clipShape(RoundedRectangle(cornerRadius: isHovered ? 16 : 12))

            if isHovered {
                expandedContent(for: clip)
                    .padding(8)
                    .transition(.opacity)
            } else {
                thumbnailContent(for: clip)
                    .padding(6)
                    .transition(.opacity)
            }
        }
        .frame(width: slotSize, height: slotSize)
        .shadow(
            color: .black.opacity(isHovered ? 0.35 : 0.12),
            radius: isHovered ? 14 : 4,
            x: 0, y: isHovered ? 4 : 1
        )
        // contentShape ensures the hit area matches the fixed frame, not the visual content
        .contentShape(Rectangle())
        .animation(.spring(response: 0.2, dampingFraction: 0.82), value: isHovered)
        .onHover { entering in
            hoveredID = entering ? clip.id : (hoveredID == clip.id ? nil : hoveredID)
        }
        .onTapGesture { onSelect(clip) }
    }

    // Compact thumbnail shown when not hovered
    @ViewBuilder
    private func thumbnailContent(for clip: Clip) -> some View {
        if clip.type == "image", let data = clip.blob, let nsImage = NSImage(data: data) {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else if clip.type == "file" {
            VStack(spacing: 4) {
                Image(systemName: "doc")
                    .font(.system(size: 22))
                Text(URL(fileURLWithPath: clip.content).lastPathComponent)
                    .font(.system(size: 9))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        } else {
            Text(String(clip.content.prefix(60)))
                .font(.system(size: 10))
                .lineLimit(4)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    // Full preview shown when hovered - fills the same 110×110 slot
    @ViewBuilder
    private func expandedContent(for clip: Clip) -> some View {
        if clip.type == "image", let data = clip.blob, let nsImage = NSImage(data: data) {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else if clip.type == "file" {
            VStack(spacing: 6) {
                Image(systemName: "doc.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
                Text(clip.content)
                    .font(.system(size: 10, weight: .medium))
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
            }
        } else {
            Text(clip.content)
                .font(.system(size: 11))
                .lineLimit(6)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}
