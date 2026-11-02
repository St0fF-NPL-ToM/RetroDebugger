# RetroDebugger on Fedora

> [!INFO]
> This is a private project to make RetroDebugger easily available on Fedora Linux.  Permission for redistribution pending.

<!-- TOC -->

- [Determining all requirements](#determining-all-requirements)
  - [Runtime requirements](#runtime-requirements)
  - [build time requirements](#build-time-requirements)
  - [consolidated requirements](#consolidated-requirements)
- [CI build process and package redistribution](#ci-build-process-and-package-redistribution)
  - [Terra contribution](#terra-contribution)

<!-- /TOC -->

On a Fedora-based linux system the v1.0.0 linux build of RetroDebugger does not run "out-of-the-box".

The core of the problem is `sndio-lib`, which RetroDebugger uses and links to.
This library has neither made its way into the extended, nor the default fedora package repositories.
<details><summary>
It is served via the <a href="https://docs.terrapkg.com">`Terra Repositories`</a>
</summary>
Terra is a rolling RPM package repository for Fedora Linux and its derivatives. With Terra, you can install the latest packages knowing that quality and security are assured. Terra is also a great way to distribute your software on Fedora and its derivatives.
</details>

<br/>`Terra` is an extra requirement which makes "COPR" not the best target any more: the user shouldn't need to do twice the work …

## Determining all requirements

Basically, there are `runtime requirements` and `built-time requirements`.  For redistribution, both need to be evaluated.  First up is `Terra` itself:

```bash
# enable and install the terra repository in case it isn't by default
sudo dnf install --assumeyes --nogpgcheck --repofrompath\
 'terra,https://repos.fyralabs.com/terra$releasever' terra-release terra-gpg-keys
```

### Runtime requirements

The executable itself reports:

```text
  NEEDED               libGLEW.so.2.2
  NEEDED               libGL.so.1
  NEEDED               libxcb.so.1
  NEEDED               libglib-2.0.so.0
  NEEDED               libgobject-2.0.so.0
  NEEDED               libgio-2.0.so.0
  NEEDED               libdbus-1.so.3
  NEEDED               libsndio.so.7
  NEEDED               libfreetype.so.6
  NEEDED               libX11.so.6
  NEEDED               libz.so.1
  NEEDED               libgtk-3.so.0
  NEEDED               libgdk-3.so.0
  NEEDED               libpangocairo-1.0.so.0
  NEEDED               libcairo-gobject.so.2
  NEEDED               libgdk_pixbuf-2.0.so.0
  NEEDED               libatk-1.0.so.0
  NEEDED               libpango-1.0.so.0
  NEEDED               libcairo.so.2
  NEEDED               libharfbuzz.so.0
  NEEDED               libSDL2-2.0.so.0
  NEEDED               libasound.so.2
  NEEDED               libm.so.6
  NEEDED               libgcc_s.so.1
  NEEDED               libstdc++.so.6
  NEEDED               libc.so.6

@System already brings:     libglvnd-glx    libxcb      glib2       freetype        libX11
                            zlib-ng-compat  gtk3        pango       cairo-gobject   gdk-pixbuf2
                            atk             cairo       harfbuzz    sdl2-compat     alsa-lib
                            glibc           gcc         libgcc      gcc-c++         libstdc++

Missing after a fresh "Fedora Workstation"-install: libGLEW sndio-libs
```

These dependencies can be installed using (assuming "terra" enabled):

```bash
sudo dnf install libGLEW sndio-libs --assumeyes
```

… then run `RetroDebugger` from your thumb drive …

---

### build time requirements

Building `RetroDebugger` requires the package groups `c-development` and `development-tools`. Also, it requires the `Terra` package repositories and a few development packages.

On a freshly installed system, type:

```bash
sudo dnf install --nogpgcheck --repofrompath\
 'terra,https://repos.fyralabs.com/terra$releasever' terra-release terra-gpg-keys

sudo dnf group install c-development development-tools

sudo dnf install cmake gtk3-devel sdl2-compat-devel alsa-lib-devel glew-devel sndio-devel
```

Finally, use this repository at hand: build and install "the standard CMake way".  Remember to set `CMAKE_INSTALL_PREFIX` to your desired installation root folder!

> [!NOTE] User-Local linux installs normally go into `/home/$USER/.local/`, while system-wide installs target `/usr/` - YOU decide!

```bash
EXPORT CMAKE_INSTALL_PREFIX=/usr
git clone https://gitlab.com/copr-projekte/retrodebugger.git
mkdir retrodebugger/build
cd retrodebugger/build
cmake -S .. -B .
cmake --build .
cmake --install .
```

… and it is installed on your box for all users.

### consolidated requirements

With a few "smaller steps", the dependencies boiled down to:

- Runtime: `libGLEW`, `sndio-lib`
- Build Time: `gcc-c++` `cmake` `gtk3-devel` `sdl2-compat-devel` `alsa-lib-devel` `glew-devel` `sndio-devel`

---

## CI build process and package redistribution

The author already maintains "copr-projekte" as a repository for Fedora-wide manual redistribution of own software [(COPR)](https://copr.fedoraproject.org), so it was the first logical impulse to go to get Retrodebugger up and running on the author's machines …

… prior to finding out about the "Terra"-requirement.

With "Terra" being involved in any case - why not use Terra as the redistribution way?

### Terra contribution

- [x] fork the terra "packages" repository
- [x] create folder for application
- [x] insert build instructions and desktop_entry build instructions (in case not provided by the build)
- [ ] test - mock until:
  - [x] it runs
  - [ ] and contribution requirements are met
- [ ] pull request to terra …
