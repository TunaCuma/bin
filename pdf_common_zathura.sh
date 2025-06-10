#!/usr/bin/env bash
# pdf_common.sh - Common functions for PDF scripts

open_pdf_in_tmux() {
    local session_name=$1
    local pdf_path=$2
    tmux send-keys -t "$session_name" "zathura \"$pdf_path\"; tmux kill-session -t \"$session_name\"" C-m
    i3-msg "workspace 2; layout tabbed"
}

handle_pdf_session() {
    local selected_name=$1
    local pdf_file=$2
    local previous_session
    previous_session=$(tmux display-message -p '#S')
    local tmux_running
    tmux_running=$(pgrep tmux)

    # If no tmux session is running, create a new one
    if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
        tmux new-session -s "$selected_name" -c "$(dirname "$pdf_file")" -d
        tmux attach -t "$selected_name"
        open_pdf_in_tmux "$selected_name" "$pdf_file"
        tmux switch-client -t "$previous_session"
        return 0
    fi

    # If tmux is running but no session exists for the selected PDF, create one
    if [[ -z $TMUX ]] && [[ -n $tmux_running ]]; then
        tmux new-session -s "$selected_name" -c "$(dirname "$pdf_file")" -d
        tmux attach -t "$selected_name"
        open_pdf_in_tmux "$selected_name" "$pdf_file"
        tmux switch-client -t "$previous_session"
        return 0
    fi

    # If a tmux session exists for the selected PDF, switch to it and open the PDF
    if ! tmux has-session -t="$selected_name" 2>/dev/null; then
        tmux new-session -ds "$selected_name" -c "$(dirname "$pdf_file")"
        open_pdf_in_tmux "$selected_name" "$pdf_file"
        tmux switch-client -t "$previous_session"
        return 0
    fi

    tmux switch-client -t "$selected_name"
    open_pdf_in_tmux "$selected_name" "$pdf_file"
    tmux switch-client -t "$previous_session"
}
