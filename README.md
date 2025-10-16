# New VM Dependencies & Terminal Setup

```shell
# Clear out old settings (if present)
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
```
## Dependencies & Terminal
```bash
# Install dependencies
sudo apt update
sudo apt upgrade

# Dev packages
sudo apt install net-tools
sudo apt install xclip

# Nvim dependencies
sudo apt install ripgrep
sudo snap install nvim --classic
sudo apt install vim
sudo apt install curl

# If using python, install nodejs dependency for pyright
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install nodejs -y

# Git setup
sudo apt install git
git config --global user.name "<name>"
git config --global user.email "<email>"
git config --global core.editor nvim
ssh-keygen -t rsa -b 4096
ssh-add ~./ssh/id_rsa

# Download Hackfont - https://www.nerdfonts.com/font-downloads
cd ~/Downloads
sudo unzip Hack.zip -d /usr/local/share/fonts
# Go to terminal preferences and select Hackfont mono
sudo fc-cache -f -v
# Close terminal, open another

# Terminal Catpuccin theme
# https://github.com/catppuccin/gnome-terminal
curl -L https://raw.githubusercontent.com/catppuccin/gnome-terminal/v1.0.0/install.py | python3 -
# Go go terminal preferences, set as default
# Close terminal, open another
```

## Tmux 
```bash
# Install tmux and plugin manager
sudo apt install tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 

# Create config file
vim ~/.tmux.conf
```

### Tmux config file settings
```bash
unbind r
bind r source-file ~/.tmux.conf

set -g prefix C-s
set -g status off
set -g mouse on

# Show colors in terminal
set -g default-terminal "screen-256color"
# Fix mismatched terminal + nvim colors
set-option -sa terminal-features ',xterm-256color:RGB'

# Enable native OSC 52 clipboard handling (Remote copy/paste)
set -s set-clipboard on
# Allow Neovim to send escape sequences (images, clipboard) through Tmux
set -g allow-passthrough on

# When ssh'd into a robot with only vim, escape key delay causes problems with tmux
set-option -g escape-time 0

# Use Vi mode keys
setw -g mode-keys vi

# ----------------------------------------------------------------------
# DETECT NEOVIM
# Check if the current pane is running Nvim. Used for Smart Nav & Resize.
# ----------------------------------------------------------------------
is_nvim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

# ----------------------------------------------------------------------
# SMART NAVIGATION (Ctrl + h/j/k/l)
# Fixes the Telescope issue. If in Nvim, we send keys there. If not, we switch panes.
# ----------------------------------------------------------------------
bind-key -n C-h if-shell "$is_nvim" 'send-keys C-h' 'select-pane -L'
bind-key -n C-j if-shell "$is_nvim" 'send-keys C-j' 'select-pane -D'
bind-key -n C-k if-shell "$is_nvim" 'send-keys C-k' 'select-pane -U'
bind-key -n C-l if-shell "$is_nvim" 'send-keys C-l' 'select-pane -R'

# ----------------------------------------------------------------------
# SMART RESIZE BINDINGS (Ctrl + s + h/j/k/l)
# ----------------------------------------------------------------------

# Resize Left (h): Send Alt-h to Nvim (allows resizing file tree)
bind -r h if-shell "$is_nvim" "send-keys M-h" "resize-pane -L 5"

# Resize Right (l): Send Alt-l to Nvim (allows resizing file tree)
bind -r l if-shell "$is_nvim" "send-keys M-l" "resize-pane -R 5"

# Resize Down (j): ALWAYS Resize Tmux Pane (Prevents Nvim scrolling issue)
bind -r j resize-pane -D 5

# Resize Up (k): ALWAYS Resize Tmux Pane
bind -r k resize-pane -U 5

# ----------------------------------------------------------------------
# COPY MODE & EXTRAS
# ----------------------------------------------------------------------

# A smart binding for entering copy mode with Ctrl-[
# It passes the key to vim if vim is active, otherwise, it enters copy mode
bind-key -n C-[ if-shell "$is_nvim" "send-keys C-[" "copy-mode"

# List of plugins
#####################################################
# Plugin manager
set -g @plugin 'tmux-plugins/tpm'

# Navigate between tmux and vim with same keybindings
# (Note: The manual bindings above take precedence, but this is good to keep)
set -g @plugin 'christoomey/vim-tmux-navigator'
#####################################################

# Initialize TMUX plugin manager (keep this line at the bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
```

### Finalize Tmux setup
```bash
# Start a new tmux session
tmux

# Source the config file to apply settings
tmux source-file ~/.tmux.conf

# Inside tmux, press Ctrl+s then I (capital i) to install plugins
```

### Install AstroNvim configuration
```bash
git clone https://github.com/EthanMBoos/astro-starter ~/.config/nvim
nvim
```

---
## Configure clangd lsp for docker projects
Install clangd in the container. Either add the dependency to the dockerfile on container build or install by cli,
```bash
# Install older clangd version 10.0 from command line
# ---------------------------------------------------
sudo apt update
sudo apt install clangd

# Install newest clangd and lldb version 20.0 from dockerfile
# -----------------------------------------------------------
ARG LLVM_VERSION=20

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        gnupg \
        lsb-release \
        software-properties-common && \
    \
    # Fetch and run the official LLVM repository installer script
    wget -O - https://apt.llvm.org/llvm.sh | bash -s -- ${LLVM_VERSION} && \
    \
    # Install both clangd and lldb from the new repository
    apt-get install -y \
        clangd-${LLVM_VERSION} \
        lldb-${LLVM_VERSION} && \
    \
    # Create generic symlinks so you can call `clangd` and `lldb`
    ln -s /usr/bin/clangd-${LLVM_VERSION} /usr/bin/clangd && \
    ln -s /usr/bin/lldb-${LLVM_VERSION} /usr/bin/lldb && \
    \
    # Clean up
    rm -rf /var/lib/apt/lists/*
```
Generate a `compile_commands.json` file. Add the following line to your top-level `CMakeLists.txt` file and re-run CMake.
```bash
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
```

Configure `astrolsp.lua` to match the docker environment,
```bash
clangd = {
        cmd = {
          "docker",
          "exec",
          "-i",
          "<docker_container>", -- EDIT THIS
          "clangd",
          "--background-index",
          "--path-mappings=/home/<user>/code=/home/<docker_user>", -- EDIT THIS
          "--compile-commands-dir=/home/<docker_user>/project/build", -- EDIT THIS
        },
      },
```
Verify the setup. Run `:LspInfo` in Neovim to confirm that the clangd client is attached and running. If not installed, run `:Mason` and press the `i` key on clangd.

## Pyright lsp
Configure `astrolsp.lua` to match your host python installation location,
```bash
pyright = {
         settings = {
           python = {
             pythonPath = "/usr/bin/python3",
           },
         },
       },
```

## Configure lldb debug server (working the kinks out)
Add this entry to `docker-compose.yml`
```yaml
# Grant the container ptrace() process control
cap_add:
    -SYS_PTRACE
```

Edit `dap-cpp.lua` to match docker project file path.
```bash
sourceMap = {
    ["/home/<docker_user>"] = "${workspaceFolder}", -- EDIT THIS
},
```

Run cmake with an added flag: `-DCMAKE_BUILD=DEBUG`

Start the container and get the PID
```bash
docker start <container_name>
docker exec <container_name> ps -aux
```

Initiate the debugger
```bash
# Set breakpoints in AstroNvim using <Leader>db
docker exec -it oracle-development_1 lldb-server gdbserver --listen "*12345" --attach <PID>
```

---

**Tmux hotkeys**,
| Action              | Keybinding                          |
| :------------------ | :---------------------------------- |
| **Enter Prefix** | `Ctrl` + `s`                        |
| **Navigate Panes** | `Ctrl` + `h` / `j` / `k` / `l`      |
| **Resize Panes** | `Ctrl` + `s` then `h` / `j` / `k` / `l` |
| **Install Plugins** | `Ctrl` + `s` then `I` (capital i)   |

**Neovim hotkeys**,
| Keybinding | Description | Category |
| :--- | :--- | :--- |
| `<Leader>` `H` | Switch between header/source file (Clangd) | **C++/LSP** |
| `<Leader>` `h` | Switch between header/source file (Generic) | **C++/LSP** |
| `<Leader>` `fd` | Go to Definition | **C++/LSP** |
| `<Leader>` `fr` | Go to References | **C++/LSP** |
| `<Leader>` `re` | **(Visual)** Extract selected code to a function | **Refactoring** |
| `<Leader>` `rv` | **(Visual)** Extract selected code to a variable | **Refactoring** |
| `<Leader>` `ri` | Inline variable under cursor or in selection | **Refactoring** |
| `<Leader>` `rr` | Select a refactor to apply | **Refactoring** |
| `<Leader>` `rdp` | Add a debug print statement (`std::cout << "HERE" ...`) | **Refactoring** |
| `<Leader>` `rdv` | Print variable under cursor or in selection | **Refactoring** |
| `<Leader>` `gdd` | Open diff view of the working tree | **Git (Diffview)** |
| `<Leader>` `gdm` | Compare current branch with `master` | **Git (Diffview)** |
| `<Leader>` `gdf` | View current file's git history | **Git (Diffview)** |
| `<Leader>` `gdc` | Close all diff views | **Git (Diffview)** |
| `<Leader>` `ghp` | Preview the git hunk under the cursor | **Git (Gitsigns)** |
| `<Leader>` `ghs` | Stage the git hunk under the cursor | **Git (Gitsigns)** |
| `<Leader>` `ghr` | Reset the git hunk under the cursor | **Git (Gitsigns)** |
| `<Tab>` | Go to the next buffer | **Buffers** |
| `<S-Tab>` | Go to the previous buffer | **Buffers** |

---
### Bonus: VirtualBox Guest Additions
Install dependencies
```bash
sudo apt install build-essential dkms
```

With vm closed go to vbox vm Settings > Display > Enable 3D Acceleration

Insert guest additions cd image.

Double click on cd in banner. Open in terminal.
```bash
sudo ./VBoxLinuxAdditions.run
```
Restart vm.

Enable autoresize and bidirectional keyboard.
