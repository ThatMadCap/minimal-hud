<h1 align="center">
  Minimal HUD
  <br>
</h1>

![minimal-hud](https://github.com/user-attachments/assets/02225904-50ac-4258-b08c-ec54495b875e)

<p align="center">
  <img src="https://github.com/user-attachments/assets/50a2c3e2-9c73-4176-a92b-4a86a8519ac7" width="19%" />
  <img src="https://github.com/user-attachments/assets/d362bb07-c78f-4e54-aff7-97df5175704d" width="19%" />
  <img src="https://github.com/user-attachments/assets/e9fc07c4-8908-4ea0-833e-de494390215c" width="19%" />
  <img src="https://github.com/user-attachments/assets/f4d4a040-3531-4d0f-bf67-43dc9df781fc" width="19%" />
  <img src="https://github.com/user-attachments/assets/d54c3376-ccf6-4e9a-9f3a-4760c8fd1255" width="19%" />
</p>

<h4 align="center">A minimal hud built for FiveM.</h4>

<p align="center">
  <a href="https://badge.fury.io/js/electron-markdownify">
    <img src="https://img.shields.io/github/downloads/ThatMadCap/minimal-hud/total?logo=github"
         alt="Repo Downloads">
  </a>
  <a> <img src="https://img.shields.io/github/contributors/ThatMadCap/minimal-hud?logo=github"> </a>
  <a> <img src="https://img.shields.io/github/v/release/ThatMadCap/minimal-hud?logo=github"> </a>
  <a> <img src="https://img.shields.io/github/downloads/ThatMadCap/minimal-hud/latest/total?logo=github"> </a>
</p>

<p align="center">
  <a href="#dependencies">Dependencies</a> •
  <a href="#how-to-use">How To Use</a> •
  <a href="#development-setup">Development Setup</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#credits">Credits</a> •
  <a href="#support">Support</a> •
  <a href="https://github.com/ThatMadCap/minimal-hud/blob/main/LICENSE">License</a>
</p>

<p align="center">The <a href="https://github.com/vipexv/minimal-hud">original repository</a> has now been archived. This fork will continue to be maintained for the FiveM community.</p>

## Dependencies

- [ox_lib](https://github.com/CommunityOx/ox_lib/releases/tag/v3.32.2)

## How to Use

- Ensure you have the dependencies installed.
- [Download the latest release](https://github.com/thatmadcap/minimal-hud/releases/latest), add to your resources, ensure in your `server.cfg`.
- Don't forget to set a framework in `config/shared.lua` and any custom logic into `config/functions.lua`.
- If using the built-in seatbelt logic, add `setr game_enableFlyThroughWindscreen true` to your `server.cfg`.
- Prints utilise [ox_lib](https://coxdocs.dev/ox_lib/Modules/Print/Shared), e.g., `set ox:printlevel "debug"` in client/server console.

Commands:
```lua
/togglehud -- toggle the HUD visibility on or off.
```
Exports:
```lua
-- state: true to show, false to hide.
exports['minimal-hud']:toggleHud(state) -- toggle HUD visiblity.
exports['minimal-hud']:toggleMap(state) -- toggle minimap visibility.
```

## Development Setup

If you want to make changes to the HUD's UI, you can follow these steps to clone and run the project locally.<br>
To clone and run this application, you'll need [Git](https://git-scm.com) and [Bun](https://bun.sh/) along with [NodeJS](https://nodejs.org/en) installed on your computer. From your command line:

```bash
# Clone this repository
git clone https://github.com/ThatMadCap/minimal-hud.git

# Go into the repository
cd minimal-hud

# Navigate to the web folder
cd web

# Install dependencies using Bun
bun install

# Run the app
bun run dev
```

## Contributing

I welcome contributions to improve minimal-hud, it would not be possible to maintain without the community. If you'd like to help enhance the resource, feel free to use discussions, open issues, or submit pull requests.  

When contributing, please keep the following in mind:
- Maintain the same style and theme as the existing HUD for a consistent user experience.
- Follow the project's coding conventions.
- Ensure any new features include appropriate tests where applicable.

I appreciate your support in keeping this resource free and accessible for the FiveM community!

## Credits

This software uses the following open source packages:

- [Node.js](https://nodejs.org/)
- [Preact](https://preactjs.com/)
- [Tailwind CSS](https://tailwindcss.com/)
- [react-icons](https://react-icons.github.io/react-icons/)
- [Jotai](https://jotai.org/)
- [Vite](https://vitejs.dev/)

## Support

If you enjoy this project and want to show your support, consider buying me a coffee:

<a href="https://ko-fi.com/madcap" target="_blank"><img src="https://assets-global.website-files.com/5c14e387dab576fe667689cf/64f1a9ddd0246590df69ea0b_kofi_long_button_red%25402x-p-500.png" alt="Support me on Ko-fi" width="250"></a>

Alternatively, if you'd like to support the original author of this HUD, vipexv, you can do so here:

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/A0A1UDRSE)


