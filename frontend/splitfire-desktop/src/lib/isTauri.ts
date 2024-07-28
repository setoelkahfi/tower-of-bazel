declare const window: Window & { __TAURI__: any }

const isTauri = () => {
  return Boolean(
    typeof window !== 'undefined' &&
    window !== undefined &&
    window.__TAURI__ !== undefined
  )
}

export default isTauri