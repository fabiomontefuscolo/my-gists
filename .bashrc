# .bashrc
shopt -s histappend
export HISTCONTROL=ignoreboth
export HISTTIMEFORMAT='%F %T '
export PROMPT_COMMAND="history -a;${PROMPT_COMMAND}"

export GLOBIGNORE="${GLOBIGNORE-'.:..'}"
export EDITOR=vim
export SYSTEMD_PAGER=cat

# Source global definitions
if [ -f /etc/bashrc ];
then
    . /etc/bashrc
fi
