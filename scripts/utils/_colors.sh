#!/usr/bin/env bash
# ANSI escape codes
# https://gist.github.com/dominikwilkowski/60eed2ea722183769d586c76f22098dd#ansi-escape-codes


# Colors:
C='\u001b[36m' # Cyan font color
M='\u001b[35m' # Magenta font color
Y='\u001b[33m' # Yellow font color
K='\u001b[30m' # Black font color
R='\u001b[31m' # Red font color
G='\u001b[32m' # Green font color
B='\u001b[34m' # Blue font color
W='\u001b[37m' # White font color

# Bright colors:
bC='\u001b[36;1m' # Bright Cyan font color
bM='\u001b[35;1m' # Bright Magenta font color
bY='\u001b[33;1m' # Bright Yellow font color
bK='\u001b[30;1m' # Bright Black font color
bR='\u001b[31;1m' # Bright Red font color
bG='\u001b[32;1m' # Bright Green font color
bB='\u001b[34;1m' # Bright Blue font color
bW='\u001b[37;1m' # Bright White font color

# Background colors:
BC='\u001b[46m' # Cyan background color
BM='\u001b[45m' # Magenta background color
BY='\u001b[43m' # Yellow background color
BK='\u001b[40m' # Black background color
BR='\u001b[41m' # Red background color
BG='\u001b[42m' # Green background color
BB='\u001b[44m' # Blue background color
BW='\u001b[47m' # White background color

# Bright Backgrounds Colors:
bBC="\u001b[46;1m" &&
  bBM="\u001b[45;1m" &&
  bBY="\u001b[43;1m" &&
  bBK="\u001b[40;1m"

bBR="\u001b[41;1m" &&
  bBG="\u001b[42;1m" &&
  bBB="\u001b[44;1m" && W="\u001b[47;1m"

CLR="\u001b[0m"
BLD="\u001b[1m"
UNRL="\u001b[4m"
RVR="\u001b[7m"

function print_flag() {
  # Stand with Ukraine
  echo -e "${bBB}"
  printf -- " %.0s" $(seq $(tput cols))
  echo -e "${CLR}""${bBY}"
  printf -- " %.0s" $(seq $(tput cols))
  echo -e "${CLR}"
}
