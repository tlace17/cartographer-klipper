#!/bin/sh
if [ ! -d "/usr/data/klipper" ]; then
  echo "Please install vanilla klipper update from here: https://github.com/K1-Klipper/installer_script_k1_and_max and try again"
  exit 1
fi
git config --global http.sslVerify false
git clone https://github.com/K1-Klipper/cartographer-klipper.git /usr/data/cartographer-klipper
chmod +x /usr/data/cartographer-klipper/install.sh
sh /usr/data/cartographer-klipper/install.sh
if [ ! -d "/usr/data/klipper/klippy/extras/cartographer.py" ]; then
  echo "I cant find the cartographer.py file something has gone horribly wrong. Please seek help in the discord"
  exit 1
fi
sed -i '/\[gcode_macro START_PRINT\]/,/CX_PRINT_DRAW_ONE_LINE/d' /usr/data/printer_data/config/gcode_macro.cfg
wget --no-check-certificate -P  /usr/data/printer_data/config/ https://raw.githubusercontent.com/K1-Klipper/cartographer-klipper/master/start_end.cfg
sed -i '/\[include printer_params.cfg\]/a\[include cartographer_macro.cfg]\' /usr/data/printer_data/config/printer.cfg
if grep -q "include start_macro_KAMP.cfg" /usr/data/printer_data/config/printer.cfg || grep -q "include start_macro.cfg" /usr/data/printer_data/config/printer.cfg; then
    sed -i 's/\[include start_(macro|macro_KAMP)\.cfg\]/[include start_stop.cfg]/g' /usr/data/printer_data/config/printer.cfg
else
    sed -i '/\[include printer_params.cfg\]/a\[include start_end.cfg]\' /usr/data/printer_data/config/printer.cfg
fi
mkdir /usr/data/backups/
mv /usr/data/printer_data/config/sensorless.cfg /usr/data/backups/
wget --no-check-certificate -P  /usr/data/printer_data/config/ https://raw.githubusercontent.com/K1-Klipper/cartographer-klipper/master/sensorless.cfg
wget --no-check-certificate -P  /usr/data/printer_data/config/ https://raw.githubusercontent.com/K1-Klipper/cartographer-klipper/master/cartographer_macro.cfg
sed -i '/\[mcu\]/i\[include cartographer_macro.cfg]' /usr/data/printer_data/config/printer.cfg
rm /etc/init.d/S55klipper_service
wget -O- --no-check-certificate https://raw.githubusercontent.com/Guilouz/Creality-K1-and-K1-Max/main/Scripts/files/services/S55klipper_service > /etc/init.d/S55klipper_service
sed -i '/\[include Helper-Script\/screws-tilt-adjust.cfg\]/d' /usr/data/printer_data/config/printer.cfg
sed -i '/\[include Helper-Script\/save-zoffset.cfg\]/d' /usr/data/printer_data/config/printer.cfg
chmod +x  /etc/init.d/S55klipper_service
sh /etc/init.d/S55klipper_service restart
