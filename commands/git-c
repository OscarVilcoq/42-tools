git config --global alias.c '!f() { git clone "$1" && cd "$(basename "$1" .git)" && echo -e "*\n!*/\n!*/*.c" > .gitignore && for i in $(seq 0 "$2"); do mkdir -p "ex$i"; done && tree && code .; }; f'
