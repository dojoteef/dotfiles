# Inspiration for this came from:
# https://github.com/mathiasbynens/dotfiles/blob/master/.macos

# OSX-only stuff. Abort if not OSX.
is_osx || return 1

#######################
# Useful functions
#######################
plistcmd="/usr/libexec/PlistBuddy -c"
function ensure_plist_key() {
  local plist key dtype
  plist=$1
  key=$(printf '%q' "$2")
  dtype=$3

  echo "Ensuring $key"

  eval $plistcmd "\"Print $key\"" $plist &> /dev/null
  if [[ $? -ne 0 ]]; then
    eval $plistcmd "\"Add $key $dtype\"" $plist
  fi
}

function set_plist_value() {
  ensure_plist_key "$1" "$2" "$4"

  local plist key value
  plist=$1
  key=$(printf '%q' "$2")
  value=$(printf '%q' "$3")

  echo "Setting $key=$value"
  eval $plistcmd "\"Set $key $value\"" $plist
}

#######################
# Themes
#######################
theme_dir="$DOTFILES/caches/themes"
theme_json_dir="$theme_dir/._json"

# Install the terminal themes if needed
e_header "Installing themes"
if [[ ! -d "$theme_dir" ]]; then
  git clone --depth 1 https://github.com/mbadolato/iTerm2-Color-Schemes.git $theme_dir
else
  cd $theme_dir && git pull
fi

e_header "Converting themes to json"
mkdir -p $theme_json_dir
find $theme_dir -iname '*.itermcolors' -print0 | while read -d $'\0' theme; do
  theme_name="$(basename "$theme" .itermcolors)"
  json_theme="$theme_json_dir/$theme_name.json"
  if [[ ! -f "$json_theme" ]]; then
    echo "Converting $theme_name to json"
    plutil -convert json "$theme" -o - | jq . > "$json_theme"
  fi
done

nerd_font="$(osx_list_nerd_fonts | head -n 1)"

#######################
# Terminal
#######################
e_header "Setting Terminal preferences"

# Only use UTF-8
defaults write com.apple.terminal StringEncodings -array 4

# Enable Secure Keyboard Entry
# See: https://security.stackexchange.com/a/47786/8918
defaults write com.apple.terminal SecureKeyboardEntry -bool true

echo "Setting default theme to Zenburn"
if [[ "$nerd_font" ]]; then
  $DOTFILES/bin/osx_terminal_theme Zenburn -d $theme_dir/terminal -D Zenburn -f "$nerd_font" -s 12
else
  $DOTFILES/bin/osx_terminal_theme Zenburn -d $theme_dir/terminal -D Zenburn
fi

#######################
# iTerm
#######################
if open -Ra iterm &> /dev/null; then
  e_header "Setting iTerm preferences"

  OLD_DOTVARS=$DOTVARS
  DOTVARS=("profile" "fontname" "fontsize")
  if [[ "$nerd_font" ]]; then
    DOTFONTSIZE=12
    DOTFONTNAME="$nerd_font"
    DOTPROFILE="Dotfiles"
  else
    DOTFONTSIZE=14
    DOTFONTNAME="Osaka-Mono"
    DOTPROFILE="Dotfiles"
  fi

  # Use a preset profile
  iterm_domain="com.googlecode.iterm2"
  iterm_conf_dir="$DOTFILES/conf/osx/iterm"
  preferences_dir="$HOME/Library/Preferences"
  iterm_profile_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
  if [[ -d "$iterm_profile_dir" ]]; then
    rm -f "$iterm_profile_dir/profile.json" &> /dev/null
    dot_substitute "$iterm_conf_dir/profile.json" "$iterm_profile_dir/profile.json"
    jq -s '.[0].Profiles[0] * .[1] | {"Profiles": [.]}' "$iterm_conf_dir/colors.json" "$theme_json_dir/Zenburn.json" > "$iterm_profile_dir/colors.json"
  fi

  echo "Setting $DOTPROFILE as default profile for $iterm_domain"
  if [[ ! -f "$preferences_dir/$iterm_domain.plist" ]]; then
    dot_substitute "$iterm_conf_dir/full.plist" "$preferences_dir/$iterm_domain.plist"
  else
    if [[ "$TERM_PROGRAM" == "iTerm.app" ]] || ps wwwaux | egrep -q 'iTerm\.app' >/dev/null; then
      e_error "You appear to have iTerm running. You must exit the" \
        "application before continuing."
      read -rp "Close iTerm (Press ENTER to continue)"; echo
    fi

    defaults write $iterm_domain "Default Bookmark Guid" "$DOTPROFILE"
  fi
  DOTVARS=$OLD_DOTVARS
fi


#######################
# General UI/UX
#######################

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Display ASCII control characters using caret notation in standard text views
# Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

# Disable Resume system-wide
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# But keep it enabled for Safari
defaults write com.apple.Safari NSQuitAlwaysKeepsWindows -bool true

# Disable automatic termination of inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Restart automatically if the computer freezes
sudo systemsetup -setrestartfreeze on

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

#######################
# Input
#######################

# Trackpad: disable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool false
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 0
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 0

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Set language and text formats
# Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
# `Inches`, `en_GB` with `en_US`, and `true` with `false`.
defaults write NSGlobalDomain AppleLanguages -array "en" "ru"
defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Inches"
defaults write NSGlobalDomain AppleMetricUnits -bool false

# Set the timezone; see `sudo systemsetup -listtimezones` for other values
sudo systemsetup -settimezone "America/Los_Angeles" > /dev/null

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

#######################
# Screen
#######################

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

#######################
# Finder
#######################

# Set Desktop as the default location for new Finder windows
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfLe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Enable spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Remove the spring loading delay for directories
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Show the ~/Library folder
chflags nohidden ~/Library

# Show the /Volumes folder
sudo chflags nohidden /Volumes

#################################
# Dock, Dashboard and hot corners
#################################

# Set the icon size of Dock items to 36 pixels
defaults write com.apple.dock tilesize -int 65

# Change minimize/maximize window effect
defaults write com.apple.dock mineffect -string "scale"

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Enable spring loading for all Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# Don’t show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# Top left screen corner → Mission Control
defaults write com.apple.dock wvous-tl-corner -int 10
defaults write com.apple.dock wvous-tl-modifier -int 0
# Top right screen corner → 
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0
# Bottom left screen corner → 
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0
# Bottom right screen corner → 
defaults write com.apple.dock wvous-br-corner -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

#################################
# Safari
#################################

# Show the full URL in the address bar (note: this still hides the scheme)
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Prevent Safari from opening ‘safe’ files automatically after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Hide Safari’s bookmarks bar by default
defaults write com.apple.Safari ShowFavoritesBar -bool false

# Enable Safari’s debug menu
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# Enable the Develop menu and the Web Inspector in Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Add a context menu item for showing the Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Enable continuous spellchecking
defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true
# Disable auto-correct
defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

# Warn about fraudulent websites
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

# Disable plug-ins
defaults write com.apple.Safari WebKitPluginsEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled -bool false

# Disable Java
defaults write com.apple.Safari WebKitJavaEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false

# Block pop-up windows
defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

# Enable “Do Not Track”
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

#######################
# Activity Monitor
#######################

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

#######################
# Mac App Store
#######################

# Enable the WebKit Developer Tools in the Mac App Store
defaults write com.apple.appstore WebKitDeveloperExtras -bool true

# Enable Debug Menu in the Mac App Store
defaults write com.apple.appstore ShowDebugMenu -bool true

# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install System data files & security updates
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# Automatically download apps purchased on other Macs
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

# Turn on app auto-update
defaults write com.apple.commerce AutoUpdate -bool true

# Allow the App Store to reboot machine on macOS updates
defaults write com.apple.commerce AutoUpdateRestartRequired -bool true

#######################
# Miscellaneous
#######################

# Enable the debug menu in Disk Utility
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

#######################
# Kill affected apps
#######################

affected_apps=("Terminal" "Activity Monitor" "cfprefsd" "Dock" "Finder" "Messages" \
  "Photos" "Safari" "SystemUIServer")
if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
  e_error "You are running this from Terminal.app. After the script successfully \
    completes restart Terminal.app to ensure the changes are correctly applied."

  # Remove "Terminal" it is set as the first element in the array
  affected_apps="${affected_apps[@]:1}"
fi

e_arrow "To apply all settings you must exit the following applications: \
  $(join_strings "\n   " "${affected_apps[@]}")"
[[ $ACCEPT_DEFAULTS ]] && kill_affected='N' || read -n 1 -p "Close affected applications [y/N] " kill_affected; echo

if [[ "$kill_affected" =~ [Yy] ]]; then
  for app in ${affected_apps[@]}; do
    killall "${app}" &> /dev/null
  done
fi
echo "Done. Note that some of these changes require a logout/restart to take effect."
