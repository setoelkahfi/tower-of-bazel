import { ModeDemucs } from "@/models/mode";
import * as Form from "@radix-ui/react-form";

export function VolumeSlider(props: {
  _onVolumeChange: (mode: ModeDemucs, value: string) => void;
  isHidden: boolean;
}) {
  const { _onVolumeChange, isHidden } = props;

  return (
    <div className="grid grid-rows-1">
      <div className="grid grid-col-1">
        <label
          htmlFor="disabled-range"
          className="block mb-2 text-sm font-medium text-gray-900 dark:text-white"
        >
          Vocals
        </label>
        <input
          id="disabled-range"
          type="range"
          value="50"
          className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer dark:bg-gray-700"
          onChange={(e) => _onVolumeChange(ModeDemucs.Vocals, e.target.value)}
          defaultValue={100}
        />
      </div>
      <div className="grid grid-col-1">
        <label
          htmlFor="disabled-range"
          className="block mb-2 text-sm font-medium text-gray-900 dark:text-white"
        >
          Drums
        </label>
        <input
          id="disabled-range"
          type="range"
          value="50"
          className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer dark:bg-gray-700"
          onChange={(e) => _onVolumeChange(ModeDemucs.Drums, e.target.value)}
          defaultValue={100}
        />
      </div>
      <div className="grid grid-col-1">
        <label
          htmlFor="disabled-range"
          className="block mb-2 text-sm font-medium text-gray-900 dark:text-white"
        >
          Bass
        </label>
        <input
          id="disabled-range"
          type="range"
          value="50"
          className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer dark:bg-gray-700"
          onChange={(e) => _onVolumeChange(ModeDemucs.Bass, e.target.value)}
          defaultValue={100}
        />
      </div>
      <div className="grid grid-col-1">
        <label
          htmlFor="disabled-range"
          className="block mb-2 text-sm font-medium text-gray-900 dark:text-white"
        >
          Other
        </label>
        <input
          id="disabled-range"
          type="range"
          value="50"
          className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer dark:bg-gray-700"
          onChange={(e) => _onVolumeChange(ModeDemucs.Other, e.target.value)}
          defaultValue={100}
        />
      </div>
    </div>
  );
}
