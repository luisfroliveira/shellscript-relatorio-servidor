#!bin/sh

server='localhost'
ports='80 22 443 3306 70'

title='Monitor VPS'
version='1.0'

##################################### HTML ###############################################
header_html(){
    echo "
    <!DOCTYPE html>
    <html>
        <head>
            <title>$title</title>
            <meta charset='UTF-8'>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body { background-color: lightgray; color: black; max-width: 50%; margin: 0px auto; padding: 0 10px;}
                .openport {background-color: green; color: white; width: 40%; padding: 0.8%;}
                .closedport {background-color: red; color: white; width: 40%; padding: 0.8%;}
                .disk_ok {background-color: green; color: white; width: 40%; padding: 0.8%;}
                .disk_wok {background-color: yellow; color: black; width: 40%; padding: 0.8%;}
                .disk_nok {background-color: red; color: black; width: 40%; padding: 0.8%;}
            </style>
        </head>
    <body>
        <h1>$title - $version</h1>
        <p>running on $(hostname -I | sed 's/ /\n/g' | tr -s '\n' | grep -Ev '^127.0.0.1|:')</p>
        <p>Ultima atualização: $(date)</p>
        <hr>
    "
}

footer_html(){
    echo "
    </body>
    </html>
    "
}
#########################################################################################

########################## informações do sistema ######################################
system_info(){
    . /etc/os-release
    echo "<h2>"$(hostname)"</h2>"
    echo "<p><b>Distribuição:</b> "$PRETTY_NAME"</p>"
    echo "<p><b>Kernel:</b> "$(uname -r)"</p>"
    echo "<p><b>Pacotes:</b> "$(dpkg-query -f '${binary:Package}\n' -W | wc -l)" pacotes</p>"
    echo "<p><b>Uptime:</b> "$(uptime -p | sed 's/up//')"</p>"

    echo "<hr>"
}

#Portas
chekc_ports(){
    echo "<h2>Checando portas</h2>"

    for checkPorts in $ports; do
        if nc -w 1 -z $server $checkPorts; then
            echo "<p class=openport>$checkPorts [OPEN]</p>"
        else
            echo "<p class=closedport>$checkPorts [CLOSED]</p>"
        fi
    done

    echo "<hr>"
}

logged_users(){
    echo "<h2>Quem está online?</h2>"
    echo "<p>$(who | wc -l) usuario(s) online</p>"
    echo "<hr>"
}

disk_info(){
    name_root_disk=$(df -h 2>/dev/null | grep '/$' | awk '{print $1}')
    disk_total_size=$(df -h 2>/dev/null | grep -vE '^udev|tmps|none|cdrom|udev')

    disk_size=$(df -h 2>/dev/null | grep '/$' | awk '{print $5}' | tr -d %)

    echo "<h2>Informações do Disco</h2>"
    if [ "$disk_size" -le 70 ]; then
        echo "<p class=disk_ok><b>Otimo:</b> $name_root_disk ${disk_size}% usado</p>"
    elif [ "$disk_size" -le 70 ]; then
        echo "<p class=disk_wok><b>Atenção:</b> $name_root_disk ${disk_size}% usado</p>"
    elif [ "$disk_size" -ge 80 ]; then
        echo "<p class=disk_nok><b>Perigo:</b> $name_root_disk ${disk_size}% usado</p>"
    fi
    echo "<hr>"
}
#########################################################################################

################################# Carregando HTML ######################################
header_html

system_info
disk_info
chekc_ports
logged_users

footer_html
#########################################################################################