import { useState, useEffect } from 'react';

export function useCountDown() {
  const [secondsLeft, setSecondsLeft] = useState(0);

  useEffect(() => {
    if (secondsLeft <= 0) return

    const timerId = setTimeout(() => setSecondsLeft(secondsLeft - 1), 1000);
    return () => clearTimeout(timerId);
  }
  , [secondsLeft]);

  function startTimer(seconds: number) {
    setSecondsLeft(seconds);
  }

  return {
    secondsLeft,
    startTimer,
  };
}