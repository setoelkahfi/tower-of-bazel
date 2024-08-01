import Image from "next/image";

export function AudioInfo(props: { }) {
  const numberPlayed = 785;
  const difficulty = "Difficulty: Hard";
  const imageUrl = "https://img.freepik.com/free-psd/square-flyer-template-maximalist-business_23-2148524497.jpg?w=1800&t=st=1699458420~exp=1699459020~hmac=5b00d72d6983d04966cc08ccd0fc1f80ad0d7ba75ec20316660e11efd18133cd"
  return (
    <div className="flex items-center space-x-4">
      <Image
        src={imageUrl}
        alt=""
        width="88"
        height="88"
        className="flex-none rounded-lg bg-slate-100"
        loading="lazy"
      />
      <div className="min-w-0 flex-auto space-y-1 font-semibold">
        <p className="text-cyan-500 dark:text-cyan-400 text-sm leading-6">
          <abbr title="Track">Played:</abbr> {numberPlayed}
        </p>
        <h2 className="text-slate-500 dark:text-slate-400 text-sm leading-6 truncate">
          Key: C Major
        </h2>
        <p className="text-slate-500 dark:text-slate-50 text-lg">{difficulty}</p>
      </div>
    </div>
  );
}
