# splitfire-desktop

SplitFire AI is an artificial intelligence app for music enthusiasts. This repo builds desktop version of SplitFire AI.

## Local development

Run only the web target:
1. Run `rails s` on the `musik88-web` repo.
2. Set `REACT_APP_SPLITFIRE_API_HOST=localhost:3001` in your `.env` file here. Local https served from port 3001.
3. Run `yarn start` on this repo. 

Run the tauri development:
1. Run `cargo tauri dev`.
2. This will run `yarn start` under the hood as the `beforeDevCommand` command.
3. Check the `tauri.conf.json` in the `src-tauri` for full settings.

## CI/CD

The web build workflow is from [this tutorial](https://zellwk.com/blog/github-actions-deploy/).

## New framework

[Grid layout](https://github.com/react-grid-layout/react-grid-layout)