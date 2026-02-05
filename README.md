# AptoUI

## Installation

The addons are most easily installed by downloading it via WowUp.

1. On repository page click **Code** and copy the HTTPS URL shown.
2. In WowUp, select **Get Addons** → **Install from URL**.
3. Paste the HTTPS URL in and click **Import**, then **Install**.

Verify under **My Addons** that the addon is installed.

### Configuring WowUp

You need to configure WowUp to use a Personal Access Token associated with a Github user account.
Otherwise you are prone to receiving vague installation errors.
Please use your own Github user account and token.

[You can generate a Personal Access Token from this link.](https://github.com/settings/tokens/new)

You need to set the scopes. I believe you only need the following:

- **read:packages**

Generate your token and copy it. In WowUp visit **Options** → **Addons** and paste in your Personal Access Token.

## Background

This was originally intended to be a bit of discovery work to see if I could build a
replacement for the player frame (health and resource bars) based on a WeakAura setup
that I previously had.

It's turned into something a bit more, where I'm now tweaking numerous parts of the UI.
Now that I've worked out how, I'm going to split these different elements into separate addons,
with a central `AptoUI` addons that contains core / shared elements.

You can find me as `dukes__ / @dukes` on Discord in the `No Pressure EU` server.

### AptoHUD

The setup is for a hud surrounding the character, where:

- the bottom-left third is the player health
- the bottom-right third is the main player resource (mana, energy, rage, runic power, etc)
- additional resources show as a set of icons inside the bottom-right third (combo points, etc)

### AptoCastBars

Customisation of the cast bar. At present this is fairly minor but I might go back to it to
make it more custom if I end up overhauling more of the UI.

### AptoReminders

Buff reminders. These only work out of combat (because of "secret" restrictions in 12.0 onwards)
which pop up text in the middle of the screen.

## Blizzard documentation

The documentation provided by Blizzard is generally not very good. There is a github repo
with some information provided:

https://github.com/Gethe/wow-ui-source/tree/0944c3ad44986a9d61cc766caafc7a71f8e35296/Interface/AddOns

## Community documentation

There are numerous community resources, but many of these are out of date with 12.0 (at least
at the time of writing).

One guide written more recently but aimed at providing information for an LLM is below:

https://github.com/Amadeus-/WoWAddonDevGuide

## Use of AI

I used Copilot to help me build this, although it was more along the lines of a helper rather than
handing over coding duties entirely. There is not a lot of code that has been written by Copilot
and I would urge caution for anyone else using Copilot or other AI tools due to the wealth
of addons and documentation of the pre-Midnight system that fundamentally doesn't work
any longer due to the changes to the addon ecosystem and the implementation of secret values
for many items.

## License

MIT licence, see LICENCE.MD
