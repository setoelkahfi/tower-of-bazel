import { HTTPStatusCode } from "@/app/_src/components/pages/esef/SplitFireView";
import {
  AudioFile,
  Status,
} from "@/app/_src/components/player/models/AudioFile";
import { UserContext } from "@/app/_src/lib/CurrentUserContext";
import requestSplitService, {
  SplitResponse,
} from "@/app/_src/lib/requestSplitService";
import { CountdownTimerIcon, LapTimerIcon, RocketIcon } from "@radix-ui/react-icons";
import { useRouter } from "next/navigation";
import { useContext, useState } from "react";
import { Spinner } from "react-bootstrap";

enum State {
  LOADING,
  LOADED,
  ERROR,
}

export default function ButtonGenerateBackingTracks(props: {
  providerId: string;
  audioFile: AudioFile | null;
  aggregateVotes: number;
}) {
  const [state, setState] = useState(State.LOADED);
  const { user } = useContext(UserContext);
  const [goToLogin, setGoToLogin] = useState(false);
  const [audioFile, setAudioFile] = useState<AudioFile | null>(null);
  const router = useRouter();

  useState(() => {
    setAudioFile(props.audioFile);
  });

  const splitRequest = () => {
    if (!user || !user.accessToken) {
      setGoToLogin(true);
      return;
    }

    setState(State.LOADING);
    requestSplitService(props.providerId, user.accessToken)
      .then((res) => {
        console.log(res);
        const response: SplitResponse = res.data;
        if (response.code === HTTPStatusCode.OK) {
          setAudioFile(response.audio_file);
          setState(State.LOADED);
        } else {
          setState(State.ERROR);
        }
      })
      .catch((error) => {
        console.log(error);
        setState(State.ERROR);
      });
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
  const isReadyToSplit = props.aggregateVotes > splitTreshold;

  if (goToLogin) {
    router.push("/login");
    return;
  }

  if (state === State.LOADING) {
    return (
      <div className="mb-3 mt-3">
        <Spinner animation="border" role="status">
          <span className="visually-hidden">Loading...</span>
        </Spinner>
      </div>
    );
  }
  // Check if we have processed the split request.
  if (isDoneSplitting) {
    return (
      <div className="mb-3 mt-3">
        <h1 className="">Let's Play!</h1>
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
    <div className="mb-3 mt-3" title="Not enough votes to generate backing tracks...">
      <CountdownTimerIcon width={40} height={40} className="mb-3" color="red" />
    </div>
  );
}
