export default interface LyricSynch {
    id: number,
    lyric: string,
    time: string
}

export function compare(a: LyricSynch, b: LyricSynch) {
    if (a.id < 0) {
        return 0
    }
    if (a.id < b.id) {
        return -1
    }
    return 0
}