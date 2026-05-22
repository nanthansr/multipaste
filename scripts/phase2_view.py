with open('Sources/multipaste/TooltipView.swift', 'r') as f:
    content = f.read()

content = content.replace('let content: String', 'let clip: Clip')
content = content.replace('Text(content)', '''
            if clip.type == "image", let data = clip.blob, let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 150)
            } else if clip.type == "file" {
                HStack {
                    Image(systemName: "doc")
                    Text(clip.content)
                }
            } else {
                Text(clip.content)
            }
''')

with open('Sources/multipaste/TooltipView.swift', 'w') as f:
    f.write(content)
