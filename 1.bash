#!/bin/bash
#

RD=$(echo "\033[01;31m")
CL=$(echo "\033[m")
YW=$(echo "\033[33m")
HOLD="-"
HOLD_ERR="${RD}X${CL}"

settings_bashrc()
{
    msg_info "settings bash"
    sed -i.bak 's/#alias ll=/alias ll=/' /home/$SUDO_USER/.bashrc
    sed -i 's/#alias ls=/alias ls=/' /home/$SUDO_USER/.bashrc
    sed -i 's/#alias grep=/alias grep=/' /home/$SUDO_USER/.bashrc
    sed -i 's/#alias la=/alias la=/' /home/$SUDO_USER/.bashrc
    sed -i 's/#alias ls=/alias ls=/' /home/$SUDO_USER/.bashrc
}
cp_bashrc_all()
{
    msg_info "copy bashrc all new users"
    cp /home/$SUDO_USER/.bashrc /etc/skel/.bashrc
}
cp_vimrc_all()
{
    msg_info "copy vimrc all new users"
    cp /home/$SUDO_USER/.bashrc /etc/skel/.vimrc
}

settings_vimrc()
{
	msg_info "settings vim"
	rm -f /home/$SUDO_USER/.vimrc
	echo "syntax on" >> /home/$SUDO_USER/.vimrc
	echo "color darkblue" >> /home/$SUDO_USER/.vimrc
	echo "command W :execute ':silent w !sudo tee % > /dev/null' | :edit!" >> /home/$SUDO_USER/.vimrc
    echo "set smartindent" >> /home/$SUDO_USER/.vimrc
	echo "set tabstop=4" >> /home/$SUDO_USER/.vimrc
	echo "set shiftwidth=4" >> /home/$SUDO_USER/.vimrc
	echo "set smarttab" >> /home/$SUDO_USER/.vimrc
	echo "set expandtab" >> /home/$SUDO_USER/.vimrc
    echo ":map <F5> <Esc>:wq<Enter>" >> /home/$SUDO_USER/.vimrc 
}
msg_info() {
	echo -en "\033[33;1;44m"
    clear
    li=$(tput lines)
    tput cup $li
    local msg="$1"
	echo -ne " ${HOLD} ${YW}${msg}...\n"
}
msg_error()
{
	local msg="$1"
	echo -e "${HOLD_ERR} ${RD}${msg}${CL} \n"
}

msg_default()
{
    tput sgr0
    clear
}
clear
if [[ $EUID -ne 0 ]]; then
	msg_error "Данный скрипт работает только с правами суперпользователя"
	exit 1
fi

RESULT=$(apt | tr -s '\r\n' ' ' | cut -d ' ' -f1)
if [[ "$RESULT" == "apt" ]]; then
	msg_info "update sources.list"
        sed -i.bak 's/deb cdrom/#deb cdrom/' /etc/apt/sources.list
	CHOICE=$(whiptail --title "Vim" --menu "Сделать основным редактором Vim или nano" 14 58 2 "vim" " " \
	       	"nano" " " 3>&2 2>&1 1>&3)
	case $CHOICE in
		vim)

			msg_info "Update"
			apt update &>/dev/null
			msg_info "remove nano"
			apt remove nano -y &>/dev/null
			msg_info "install vim"
			apt install vim -y &>/dev/null
            settings_vimrc			
            settings_bashrc
            cp_bashrc_all
            cp_vimrc_all
            msg_default
            ;;
		nano)
			msg_info "Update"
			apt update &>/dev/null
			msg_info "remove vim"
			apt remove vim -y &>/dev/null
			msg_info "install nano"
			apt install nano -y &>/dev/null
            settings_bashrc
            cp_bashrc_all
            msg_default
			;;
	esac
    msg_info "UPGRADE"
    apt dist-upgrade -y 1>/dev/null 2>/dev/null
    apt autoremove 1>/dev/null 2>/dev/null
    apt autoclean 1>/dev/null 2>/dev/null

else
	echo "Using non apt"
fi
msg_default
