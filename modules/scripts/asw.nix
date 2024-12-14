{pkgs, ...}:
pkgs.writeShellScriptBin "asw" ''
  # asw.sh - audio switcher
  # Usage: `asw h` for headset, `asw i` for Index

  # Find sink and source names by running:
  # pw-cli list-objects Node

  if [[ $1 = 'h' ]] # Headset or speakers
  then
          ${pkgs.pulseaudio}/bin/pactl set-default-sink "alsa_output.pci-0000_0c_00.4.iec958-stereo"
          ${pkgs.pulseaudio}/bin/pactl set-default-source "alsa_input.usb-C-Media_Electronics_Inc._USB_PnP_Sound_Device-00.iec958-stereo"
  elif [[ $1 = 'i' ]] # Index
  then
          ${pkgs.pulseaudio}/bin/pactl set-default-sink "alsa_output.pci-0000_0b_00.1.hdmi-stereo-extra2"
          ${pkgs.pulseaudio}/bin/pactl set-default-source "alsa_input.usb-Valve_Corporation_Valve_VR_Radio___HMD_Mic_C84527EC3C-LYM-01.mono-fallback"
  else
          echo "\`asw h\` for headset, \`asw i\` for Index"
  fi
''
