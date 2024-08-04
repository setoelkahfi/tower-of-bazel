import { LoadingView } from "@/components/ui/LoadingView";
import { UserContext } from "@/lib/current-user-context";
import { AudioFile, Status } from "@/models/audio-file";
import { CountdownTimerIcon, LapTimerIcon, RocketIcon } from "@radix-ui/react-icons";
import { useRouter } from "next/navigation";
import { useContext, useState } from "react";

enum State {
  LOADING,
  LOADED,
  ERROR,
}

export default function ButtonGenerateBackingTracks({ 
  songProviderId, 
  audioFile, 
  aggregateVotes
}: {
  songProviderId: number;
  audioFile: AudioFile | null;
  aggregateVotes: number;
}) {

  const [state, setState] = useState(State.LOADED);
  const { user } = useContext(UserContext);
  const [goToLogin, setGoToLogin] = useState(false);
  const router = useRouter();

  const splitRequest = () => {
    if (!user || !user.accessToken) {
      setGoToLogin(true);
      return;
    }

    setState(State.LOADING);
    // Split request logic here.

  };

  // Default to production value.
  const splitTreshold = process.env.REACT_APP_SPLIT_THRESHOLD
    ? parseInt(process.env.REACT_APP_SPLIT_THRESHOLD)
    : 5;

  const isDoneSplitting = audioFile && audioFile.status === Status.DONE;
  const isCurrentlySplitting =
    audioFile &&
    (audioFile.status === Status.SPLITTING ||
      audioFile.status === Status.DOWNLOADING);
  const isReadyToSplit = aggregateVotes > splitTreshold;

  if (goToLogin) {
    router.push("/login");
    return <></>;
  }

  if (state === State.LOADING) {
    return (
      <div className="mb-3 mt-3">
        <LoadingView />
      </div>
    );
  }
  // Check if we have processed the split request.
  if (isDoneSplitting) {
    return (
      <div className="mb-3 mt-3">
        <h1 className="">Let&apos;s Play!</h1>
      </div>
    );
  } else if (isCurrentlySplitting) {
    return (
      <div className="mb-3 mt-3" title="Split request in progress...">
        <LapTimerIcon
          width={40}
          height={40}
          className="mb-3"
          color="red"
        />
      </div>
    );
  } else if (isReadyToSplit) {
    return (
      <div className="mb-3 mt-3" 
      title="Split request...">
        <RocketIcon
          width={40}
          height={40}
          className="mb-3 cursor-pointer"
          onClick={splitRequest}
          color="blue"
        />
      </div>
    );
  }

  return (
    <div className="" title="Not enough votes to generate backing tracks...">
      <CountdownTimerIcon width={40} height={40} className="mb-3" color="red" />
    </div>
  );
}
