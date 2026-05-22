import SwiftUI

struct TooltipView: View {
    let clip: Clip
    let index: Int
    let total: Int
    
    var body: some View {
        HStack {
            Text("\(index + 1)/\(total)")
                .font(.caption)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(Color.gray.opacity(0.3)))
            
            if clip.type == "image", let data = clip.blob, let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 150)
            } else if clip.type == "file" {
                HStack {
                    Image(systemName: "doc")
                    Text(clip.content)
                        .lineLimit(3)
                }
            } else {
                Text(clip.content)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(VisualEffectView(material: .menu, blendingMode: .behindWindow))
        .cornerRadius(8)
        .shadow(radius: 4)
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
