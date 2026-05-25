import { ClipItem } from './types';

export const DEMO_CLIPS: ClipItem[] = [
  {
    id: '1',
    type: 'code',
    content: 'func configureEventTap() -> CFMachPort? {\n  let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)\n  return CGEvent.tapCreate(tap: .cgSessionEventTap, ...)\n}',
    title: 'CGEventTap setup',
    sourceApp: 'Xcode',
    timeAgo: '12s',
  },
  {
    id: '2',
    type: 'text',
    content: 'MULTIPASTE_GUMROAD_URL=https://gumroad.com/l/multipaste',
    title: 'ENV variable',
    sourceApp: 'Terminal',
    timeAgo: '45s',
  },
  {
    id: '3',
    type: 'color',
    content: '#3b82f6',
    title: 'Brand blue',
    sourceApp: 'Figma',
    timeAgo: '2m',
    colorHex: '#3b82f6',
  },
  {
    id: '4',
    type: 'link',
    content: 'https://developer.apple.com/documentation/coregraphics/cgeventtap',
    title: 'CGEventTap docs',
    sourceApp: 'Safari',
    timeAgo: '5m',
  },
  {
    id: '5',
    type: 'text',
    content: 'The rapid-fire paste buffer for your next 10 seconds.',
    title: 'Tagline draft',
    sourceApp: 'Notes',
    timeAgo: '18m',
  },
  {
    id: '6',
    type: 'code',
    content: 'INSERT INTO clips (content, type, source_app) VALUES (?, ?, ?)',
    title: 'SQLite insert',
    sourceApp: 'VS Code',
    timeAgo: '1h',
  },
];
