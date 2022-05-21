<img width="225" src="https://raw.githubusercontent.com/maculateConception/aural-player/master/Documentation/Screenshots/readmeLogo.png"/>

<img width="1024" src="https://github.com/kartik-venugopal/aural-player/raw/v4.0/aural4.png"/>

## The v4.0 goals

As of May 21, 2022, Aural Player version 4.0 is in active development, and aims to take the app to the next level, bringing improvements such as:

- A new "Unified" (single window) app presentation mode. NOTE - The existing modular UI mode will remain.
- The playlist becomes the "play queue" and the user can now save multiple playlists.
- Nicer user interface aesthetics (look and feel)
- More compact player and FX panel windows (area reduced by 20%)
- A new app setup screen on first app launch
- Simplified theming (fonts and colors)
- Improved usability
- A lot more help and tool tips
- Gapless queueing of tracks (eliminating audible gaps between tracks and segment loops)
- Cleaner source code and use of newer APIs
- Possibly an app version for iPadOS
- Possibly online streaming
- Possibly a file browser with advanced search capabilities
- Better support for multi-screen setups (window layouts)
- Plug-in architecture for visualizations (enabling developers to use / share custom visualizations) ? ... TBD

### Notes:

- Version 4.0 will only support macOS 11.0 (Big Sur) and newer versions. This is to:
  * Take advantage of more recent advancements to the AppKit framework and other features unavailable on older platforms 
  * Simplify codebase maintenance
  * Simplify app testing.
- For users on older macOS platforms, the existing 3.x releases will continue to be available and can be used instead.
- The version 3.x code will be put into a new branch, and v4.x will become the master branch.
- There may be a few bug fixes on the 3.x branch if deemed necessary, but no new feature development will occur.
