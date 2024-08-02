import { PlayIcon } from "@heroicons/react/solid";

export default function LetsPlayView(props: { onClick: () => void }) {
  const { onClick } = props;

  return (
    <div className="align-self-center col-auto">
      <PlayIcon
        onClick={onClick}
        width={50}
        cursor={"pointer"}
        color="green"
      />
    </div>
  );
}