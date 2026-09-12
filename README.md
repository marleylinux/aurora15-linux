# Aurora15-linux

A quick guide and setup script to get the Aurora 15 community revival servers working for FIFA 15 on Arch Linux using Bottles.

Thanks to [Aurora](https://aurora15.onlyonemzy.com/) for reviving FIFA 15 ❤️

---

## What this does

- Sets up a clean 64-bit Gaming bottle for FIFA 15
- Automatically applies the `dinput8` override needed for the community server hook to work
- Installs the MSVC 2012 runtime dependencies FIFA 15 needs to boot
- Adds Aurora as a shortcut in Bottles with the correct working directory
- Works cleanly with your native Linux browser for the Discord sign-in

## Requirements (Arch)

You just need Bottles and Wine installed from pacman:

```bash
sudo pacman -S bottles wine
```

Also make sure you have your graphics drivers installed (Vulkan):
- **AMD:** `vulkan-radeon lib32-vulkan-radeon`
- **NVIDIA:** `nvidia-utils lib32-nvidia-utils`
- **Intel:** `vulkan-intel lib32-vulkan-intel`

And of course, your FIFA 15 game folder with `Aurora.exe` inside it.

## The Quick Way (Setup Script)

Clone this repo and run the script:

```bash
git clone https://github.com/marleylinux/aurora15-linux
cd aurora15-linux
chmod +x setup.sh
./setup.sh
```

You can also give it your FIFA 15 path directly:

```bash
./setup.sh "/home/marley/Games/FIFA 15"
```

The script will automatically detect your files, create the bottle, set the DLL override, install the dependencies, and add the shortcut.

## How to launch & sign in

1. Open **Bottles** and find your **FIFA 15** bottle.
2. Click **Play** on **Aurora** (or run `bottles-cli run -b "FIFA 15" -p "Aurora"` from terminal).
3. On the first launch, Aurora downloads its connector files into your prefix.
4. When the launcher appears, click **Sign in with Discord**.
5. Your regular Linux browser will open up to the Discord authorization page. Click Authorize, and the browser will redirect back to the launcher automatically.
6. Pick FIFA 15 and hit Play!

## Why it breaks out of the box (The `dinput8` thing)

If you just run `Aurora.exe` in Wine without configuring anything, the game will either prompt you for Origin, boot offline, or crash.

Here's why: Aurora hooks FIFA 15's network traffic to the community servers using a custom `dinput8.dll` (an EA-MITM proxy) that it drops into the game folder. By default, Wine ignores folder-level DLLs for DirectInput and uses its own built-in one instead.

Setting `dinput8` to `native,builtin` tells Wine to prioritize Aurora's hook file over Wine's dummy file. The script does this automatically, but if you do it manually in the Bottles GUI, just go to:
**Bottle Settings → DLL Overrides → Add `dinput8` → set to `native,builtin`**.

## Controllers

Arch Linux handles controllers out of the box through the kernel:
- **PlayStation controllers (DualSense / DS4):** Plug and play natively.
- **Xbox wired / wireless dongle:** Handled by the kernel `xpad` driver out of the box.
- **Xbox Bluetooth:** Install `xpadneo-dkms` from the AUR (`yay -S xpadneo-dkms`) if you get button mapping issues over Bluetooth.

## Troubleshooting

- **Game says Origin isn't installed or won't connect online:**
  Check that the `dinput8` override is set to `native,builtin` in your bottle settings. That's what allows the Aurora hook to route the connection.
- **Discord sign-in doesn't finish:**
  Make sure your local firewall isn't blocking `127.0.0.1`. The launcher listens on a local port for the browser redirect.
- **Launcher has missing or blank text:**
  Go to the Dependencies tab in Bottles and install `allfonts`, or install `ttf-ms-fonts` from the AUR.

---

### Check out my other apps:

| [<img src="https://raw.githubusercontent.com/marleylinux/cpupower-gtk/main/src/assets/com.marley.cpupower-gtk.png" width="48" height="48" /><br/>cpupower-gtk](https://github.com/marleylinux/cpupower-gtk) | [<img src="https://raw.githubusercontent.com/marleylinux/Ryzenadj-gtk/main/src/assets/com.marley.ryzenadj-gtk.png" width="48" height="48" /><br/>Ryzenadj-gtk](https://github.com/marleylinux/Ryzenadj-gtk) | [<img src="https://raw.githubusercontent.com/marleylinux/FastFlowLM-gtk/main/src/assets/com.marley.FastFlowLM-gtk.png" width="48" height="48" /><br/>FastFlowLM-gtk](https://github.com/marleylinux/FastFlowLM-gtk) | [<img src="https://raw.githubusercontent.com/marleylinux/fetch-gtk/main/src/assets/com.marley.fetch-gtk.png" width="48" height="48" /><br/>fetch-gtk](https://github.com/marleylinux/fetch-gtk) |
|---|---|---|---|
