# Old script for configuring cinnamon in Linux Mint

THEME="'Mint-Y-Dark'"
GTK_THEME="'Mint-Y-Dark'"
ICON_THEME="'Yaru-sage'"

echo  Disabling system sounds
dconf write /org/cinnamon/sounds/login-enabled false
dconf write /org/cinnamon/sounds/logout-enabled false
dconf write /org/cinnamon/sounds/notification-enabled false
dconf write /org/cinnamon/sounds/plug-enabled false
dconf write /org/cinnamon/sounds/unplug-enabled false
dconf write /org/cinnamon/sounds/tile-enabled false
dconf write /org/cinnamon/sounds/switch-enabled false
dconf write /org/cinnamon/desktop/sound/event-sounds false
dconf write /org/cinnamon/desktop/sound/volume-sound-enabled false

echo 'Bind Alt+Win+Q "->" close window'
dconf write /org/cinnamon/desktop/keybindings/wm/close "['<Alt>F4', '<Shift><Super>q']"

echo 'Bind Ctrl+Alt+P "->" flameshot'
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/binding "['<Primary><Alt>p']"
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/command "'/usr/bin/flameshot gui'"
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/name "'flameshot'"

echo 'Bind Ctrl+Alt+T "->" terminator'
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom1/binding "['<Primary><Alt>t']"
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom1/command "'/usr/bin/terminator'"
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom1/name "'terminator'"

echo Changing theme to "$THEME"
dconf write /org/cinnamon/theme "$THEME"
dconf write /org/cinnamon/theme/name "$THEME"
dconf write /org/cinnamon/desktop/interface/gtk-theme "$GTK_THEME"
dconf write /org/cinnamon/desktop/interface/icon-theme "$ICON_THEME"

echo Enabling displaying of hidden files
dconf write /org/nemo/preferences/show-hidden-files true
dconf write /org/gtk/settings/file-chooser true
