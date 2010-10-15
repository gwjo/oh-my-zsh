# Two line prompt, based heavily on Phil's prompt (http://aperiodic.net/phil/prompt/)
#

setopt prompt_subst
autoload colors
colors

autoload -U add-zsh-hook
autoload -Uz vcs_info

# check-for-changes can be really slow.
# you should disable it, if you work with large repositories
zstyle ':vcs_info:*:prompt:*' check-for-changes true

add-zsh-hook precmd gaz_precmd_hook

gaz_precmd_hook() {
    vcs_info

    # Get the width of the terminal
    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 1 ))

    # Calculate width prompt
    local promptsize=${#${(%):--(%n@%m:%l)---()--}}
    local pwdsize=${#${(%):-%~}}

    
    PR_FILLBAR=""
    PR_PWDLEN=""

    # Truncate the prompt if it's too long 
    if [[ "$promptsize + $pwdsize" -gt $TERMWIDTH ]]; then
        ((PR_PWDLEN=$TERMWIDTH - $promptsize))
    else
        PR_FILLBAR="\${(l.(($TERMWIDTH - ($promptsize + $pwdsize)))..-.)}"
    fi

}


PROMPT='%{$fg[cyan]%}-%{$fg_bold[blue]%}-(%{$fg[green]%}%n@%m:%l%{$fg_bold[blue]%})-%{$fg[cyan]%}${(e)PR_FILLBAR}%{$fg_bold[blue]%}-(%{$fg[magenta]%}%$PR_PWDLEN<...<%~%<<%{$fg_bold[blue]%})-%{$fg[cyan]%}-
-%{$fg_bold[blue]%}-(%(?..%{$fg[red]%}$?%{$fg_bold[blue]%}:)%{$fg[yellow]%}%T%{$fg_bold[blue]%}:%(!.%{$fg[red]%}.%{$fg[white]%})%#$(git_prompt_info)%{$fg_bold[blue]%})-%{$fg[cyan]%}- %{$reset_color%}'

PS2='%{$fg[cyan]%}-%{$fg_bold[blue]%}-(%{$fg[green]%}%_%{$fg_bold[blue]%})-%{$fg[cyan]%}- %{$reset_color%}'

RPROMPT='  %{$fg[cyan]%}-%{$fg_bold[blue]%}-(%{$fg[yellow]%}%D{%a,%b%d}%{$fg_bold[blue]%})-%{$fg[cyan]%}-%{$reset_color%}'


ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}:%{$fg[magenta]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[magenta]%}) %{$fg[yellow]%}#%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

#  vim: set ft=zsh ts=4 sw=4 et:
