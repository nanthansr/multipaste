export type ClipType = 'text' | 'code' | 'color' | 'link' | 'image';

export interface ClipItem {
  id: string;
  type: ClipType;
  content: string;
  title?: string;
  sourceApp: string;
  timeAgo: string;
  colorHex?: string;
}
