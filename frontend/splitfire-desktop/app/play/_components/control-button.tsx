import {
  BookmarkIcon,
  PauseIcon,
  CircleIcon,
  BookmarkFilledIcon,
  ResumeIcon,
  PlayIcon,
  ResetIcon,
} from "@radix-ui/react-icons";
import { useLogger } from "@/app/_src/lib/logger";
import { useState } from "react";

export function ControlButtons(props: {
  isPlaying: boolean;
  isRecording: boolean;
  onClick: () => void;
  onStop: () => void;
  onRecord: () => void;
  onResume: () => void;
}) {
  const log = useLogger("ControlButtonsV2");
  const { isPlaying, isRecording } = props;
  const [isBookmarked, setIsBookmarked] = useState(false);

  const toggleBookmark = () => {
    log.debug("toggleBookmark");
    setIsBookmarked(!isBookmarked);
  };

  const bookMarkText = isBookmarked
    ? "Remove from bookmarks"
    : "Add to bookmarks";
  const recordingText = isRecording ? "Recording" : "Stop recording";

  let playPauseResumeIcon = isPlaying ? (
    <PauseIcon color={"black"} width="24" height="24" />
  ) : (
    <PlayIcon color={"black"} width="24" height="24" />
  );
  if (isRecording) {
    playPauseResumeIcon = <ResumeIcon color={"black"} width="24" height="24" />;
  }

  return (
    <div className="bg-slate-50 text-slate-500 py-6 dark:bg-slate-600 dark:text-slate-200 rounded-b-xl flex items-center">
      <div className="flex-auto flex items-center justify-evenly">
        <button
          type="button"
          aria-label={bookMarkText}
          onClick={toggleBookmark}
          title={bookMarkText}
        >
          {isBookmarked ? (
            <BookmarkFilledIcon color={"black"} width="24" height="24" />
          ) : (
            <BookmarkIcon color={"black"} width="24" height="24" />
          )}
        </button>
        <button
          type="button"
          aria-label="Record"
          disabled={isPlaying}
          title={recordingText}
        >
          <CircleIcon
            color={isRecording ? "blue" : "red"}
            width="30"
            height="32"
          />
        </button>
        <button
          type="button"
          aria-label="Play/Pause/Resume"
          disabled={isRecording}
        >
          {playPauseResumeIcon}
        </button>
        <button type="button" aria-label="Restart" disabled={isRecording}>
          <ResetIcon color={"black"} width="24" height="24" />
        </button>
      </div>
    </div>
  );
}
