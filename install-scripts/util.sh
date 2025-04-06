#!/bin/bash

# Remove unwanted applications from the menu
echo "Removing unwanted applications from the menu..."

# Remove Avahi tools
echo "Removing Avahi tools..."
if ls /usr/share/applications | grep -q avahi; then
    sudo rm /usr/share/applications/avahi-discover.desktop && echo "Removed avahi-discover.desktop"
else
    echo "No Avahi tools found to remove."
fi

# Remove VNC applications
echo "Removing VNC applications..."
if ls /usr/share/applications | grep -q -i vnc; then
    sudo rm /usr/share/applications/bvnc.desktop && echo "Removed bvnc.desktop"
else
    echo "No VNC applications found to remove."
fi

# Remove SSH applications
echo "Removing SSH applications..."
if ls /usr/share/applications | grep -q -i ssh; then
    sudo rm /usr/share/applications/bssh.desktop && echo "Removed bssh.desktop"
else
    echo "No SSH applications found to remove."
fi

# Remove SSH applications
echo "Removing UserFeedback Console applications..."
if ls /usr/share/applications | grep -q -i userFeedback; then
    sudo rm -r  /usr/share/applications/org.kde.kuserfeedback-console.desktop  && echo "Removed UserFeedback Console"
else
    echo "No SSH applications found to remove."
fi

apps_to_hide=(
"jconsole-java-openjdk.desktop"
"jshell-java-openjdk.desktop"
"htop.desktop"
"qvidcap.desktop"
"qv4l2.desktop"
"vim.desktop"
"nvim.desktop"
"org.gnupg.pinentry-qt5.desktop"
"org.gnupg.pinentry-qt.desktop"
)

applications_dir="/usr/share/applications"

for app in "${apps_to_hide[@]}"; do 
   desktop_file="$applications_dir/$app"
   if [ -f "$desktop_file" ]; then
      echo "Hiding $app"
      sudo sed -i '/^NoDisplay=/d' "$desktop_file" # Remove existing NoDisplay line
      echo "NoDisplay=true" | sudo tee -a "$desktop_file" > /dev/null
   else
      echo "$app not found"
   fi
done

echo "All done!"
