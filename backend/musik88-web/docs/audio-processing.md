# Audio

The audio processing part is divided into two processes: youtube-to-audio and the split process.

## YouTube to audio

The YouTube to audio status is attached to the `audio_files` table. Homebrew is recommended installer.

```shell
brew install yt-dlp
```


## Split process

The split process status is attached to the `audio_file_split_statuses` table. Uses the system `Python3` command to install `demucs` by following the official [Linux installation](https://github.com/facebookresearch/demucs/blob/main/docs/linux.md).

```shell
pip3 install --user -U demucs

```

## Background job

`SideKiq` is used as the bakcground job. During development, you might need to cleanup redis now and then:

```shell
redis-cli flushall
```