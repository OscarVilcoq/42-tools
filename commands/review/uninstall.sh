unalias r 2>/dev/null
unset -f review 2>/dev/null
sed -i '/review()/,/alias r="review"/d' ~/.bashrc && source ~/.bashrc