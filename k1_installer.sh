#!/bin/sh
git clone https://github.com/K1-Klipper/cartographer-klipper.git /usr/data/
chmod +x /usr/cartographer-klipper/install.sh
sh /usr/cartographer-klipper/install.sh
sed -i '/\[gcode_macro START_PRINT\]/,/\[/gcode_macro START_PRINT\]/d' /usr/data/printer_config/gcode_macro.cfg
curl -o /usr/data/printer_config/start_end.cfg https://github.com/K1-Klipper/cartographer-klipper/raw/master/start_end.cfg
sed -i '/\[include printer_params.cfg\]/a\[include cartographer_macro.cfg]\' /usr/data/printer_config/printer.cfg
if grep -q "include start_macro_KAMP.cfg" your_file.txt; then
    command_if_exists
else
if grep -q "include start_macro.cfg" your_file.txt; then
    command_if_exists
else
    command_if_not_exists
fi
fi
