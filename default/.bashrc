# ~/.bashrc: executed by bash(1) for non-login shells.

# If running interactively, then:
if [ "$PS1" ]; then
	# include /etc/profile, some systems don't do this even though they should
	. /etc/profile

	# set up shell history
	export HISTCONTROL=ignoredups
	export HISTFILESIZE=100000
	export HISTSIZE=100000
	shopt -s histappend

	# check the window size after each command and, if necessary,
	# update the values of LINES and COLUMNS.
	shopt -s checkwinsize

	# add some handy aliases
	alias ll='ls -lh'
	alias la='ls -lha'
	alias pa='ps aux'
	alias paw='ps auxwww'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

	# do we have colour support?
	if [ "$TERM" != 'dumb'  ] && [ -n "$BASH" ]; then
		# enable colour support of ls
		eval `dircolors -b`
		alias ls='ls --color=auto'

		# set a fancy prompt
		if [ `/usr/bin/whoami` = 'root' ]; then
			PS1='\[\033[01;31m\]\h \[\033[01;34m\]\W \$ \[\033[00m\]'
		else
			PS1='\[\033[01;32m\]\u@\h \[\033[01;34m\]\W \$ \[\033[00m\]'
		fi
	fi

	# if term is capable, set the title to user@host:dir
	# also append to history after each command
	case $TERM in
		xterm*|rxvt|Eterm|eterm)
			PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"; history -a'
			;;
		screen)
			PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"; history -a'
			;;
		*)
			PROMPT_COMMAND='history -a'
			;;
    esac
    
	# enable programmable completion features
	[ -f /etc/bash_completion ] && . /etc/bash_completion

	# improve 'less' a bit
	[ -x /usr/bin/lesspipe ] && eval "$(/usr/bin/lesspipe)"

	# unicode-enable screen
	alias screen="screen -U"

	# funky function nicked from Red Hat and altered a little
	# adds entries to the PATH at the start or end and only if the dir exists
	pathmunge() {
		if ! echo $PATH | /bin/egrep -q "(^|:)$1($|:)" && [ -d $1 ] ; then
			if [ "$2" = "after" ] ; then
				PATH=$PATH:$1
			else
				PATH=$1:$PATH
			fi
		fi
	}

	# add some useful PATH entries
	pathmunge /usr/local/sbin
	pathmunge /usr/sbin
	pathmunge /sbin
	pathmunge $HOME/bin after
	pathmunge $HOME/opt after
	
	# clean up
	unset pathmunge
fi

export PIP_DOWNLOAD_CACHE=$HOME/.pip_download_cache
export PIP_RESPECT_VIRTUALENV=true
# Uncomment - causes problems with pip and jython 2.5.2
export PIP_USE_MIRRORS=false

# https://github.com/godlygeek/csapprox (if not starting tmux)
[ -z "$TMUX" ] && export TERM=xterm-256color
