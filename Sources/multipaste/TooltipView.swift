import SwiftUI

struct TooltipView: View {
    let clip: Clip
    let index: Int
    let total: Int
    
    var body: some View {
        contentView
            .padding(14)
            .background(
                VisualEffectView(material: .popover, blendingMode: .behindWindow)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.22), radius: 16, x: 0, y: 6)
            .overlay(alignment: .topTrailing) {
                if total > 1 {
                    Text("\(index + 1)/\(total)")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.primary.opacity(0.12)))
                        .padding(10)
                }
            }
    }

    @ViewBuilder
    private var contentView: some View {
        if clip.type == "image", let data = clip.blob, let nsImage = NSImage(data: data) {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if clip.type == "file" {
            HStack {
                Image(systemName: "doc")
                Text(clip.content)
                    .lineLimit(6)
            }
        } else {
            Text(clip.content)
                .lineLimit(6)
        }
    }
}

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
