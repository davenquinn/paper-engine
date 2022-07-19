export FIGURE_COLLECT_DIR="collected-figures"

# Legacy files need to have allexport set
set -o allexport
source "$PAPER_DIR/paper-defs.zsh"
source "$PAPER_DIR/.env"
set +o allexport

# move towards modern environment variables
export PAPER_NAME="$name"