import { MdArrowLeft, MdArrowDropDown } from "react-icons/md"

export function HideShowToggleView(props: { hideVolumeSliders: boolean, setHideVolumeSliders: (hideVolumeSliders: boolean) => void }) {

  const { hideVolumeSliders, setHideVolumeSliders } = props

  if (hideVolumeSliders) {
      return <MdArrowLeft onClick={() => setHideVolumeSliders(!hideVolumeSliders)} size={30} style={{cursor: "pointer"}} />
  }

  return <MdArrowDropDown onClick={() => setHideVolumeSliders(!hideVolumeSliders)} size={30} style={{cursor: "pointer"}} />
}