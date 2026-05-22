with open('Sources/multipaste/AppDelegate.swift', 'r') as f:
    content = f.read()
content = content.replace('\\(fifoQueue.count)', '\\(self.fifoQueue.count)')
with open('Sources/multipaste/AppDelegate.swift', 'w') as f:
    f.write(content)

with open('Sources/multipaste/ClipboardManager.swift', 'r') as f:
    content = f.read()
content = content.replace('\\(lastInjectedText?', '\\(self.lastInjectedText?')
with open('Sources/multipaste/ClipboardManager.swift', 'w') as f:
    f.write(content)

with open('Sources/multipaste/DatabaseManager.swift', 'r') as f:
    content = f.read()
content = content.replace('lastClip[content]', 'lastClip[self.content]')
with open('Sources/multipaste/DatabaseManager.swift', 'w') as f:
    f.write(content)

