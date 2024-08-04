import { useCountDown } from "@/lib/use-count-down";
import { useLogger } from "@/lib/logger";
import { useEffect } from "react";

export function AudioInfoMiddle({
  counterDownTimer,
}: {
  counterDownTimer: number;
}) {
  const timePlayed = "0:01";
  const timeTotal = "3:20";
  return (
    <div className="space-y-2">
      <div className="flex-auto flex items-center justify-evenly">
        <CountDownView
          seconds={counterDownTimer}
          type="audio"
          onCountDownEnd={() => {}}
        />
      </div>
      <div className="flex justify-between text-sm leading-6 font-medium tabular-nums">
        <div className="text-cyan-500 dark:text-slate-100">{timePlayed}</div>
        <div className="text-slate-500 dark:text-slate-400">{timeTotal}</div>
      </div>
    </div>
  );
}

function CountDownView(props: {
  seconds: number;
  type: string;
  onCountDownEnd?: () => void;
}) {
  const log = useLogger("CountDownView");
  const { secondsLeft, startTimer } = useCountDown();

  useEffect(() => {
    log.debug("start counting down seconds:", props.seconds);
    startTimer(props.seconds);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  if (secondsLeft === 0 && props.onCountDownEnd) {
    log.debug("CountDownView: onCountDownEnd");
    props.onCountDownEnd();
  }

  const displayText = secondsLeft === 0 ? props.type : secondsLeft;

  return (
    <div className="text-red-500 dark:text-slate-100">
      <h1>{displayText}</h1>
    </div>
  );
}
