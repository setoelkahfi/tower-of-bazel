'use client'

import { useLocalStorage } from '../_lib/hooks/use-local-storage';
import { cn } from '../_lib/utils';
import { ChatPanel } from '../_ui/components/chat-panel';
import { EmptyScreen } from '../_ui/components/empty-screen';
import { useChat, type Message } from 'ai/react'
import { usePathname } from 'next/navigation';
import { toast } from 'react-hot-toast'

export interface ChatProps extends React.ComponentProps<'div'> {
  initialMessages?: Message[]
  id?: string
}

export default function Page() {
  return (
    <div className="prose prose-sm prose-invert max-w-none">
    </div>
  );
}
