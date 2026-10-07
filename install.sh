#!/usr/bin/env bash

set -e
shopt -s expand_aliases

command_exists() {
	command -v "$1" >/dev/null
}

if ! command_exists sass; then
	echo "Sass was not found in your \$PATH. Please install Dart Sass >= 1.95.0 to compile this theme."
	exit 1
fi

minimum_segments=(1 95 0)
sass_version=$(sass --version)
for (( i=1; i <= 3; i++ )); do
	segment=$(echo "$sass_version" | cut -d . -f "$i")
	if (( $segment > ${minimum_segments[i - 1]} )); then
		break
	elif (( $segment < ${minimum_segments[i - 1]} )); then
		(
			IFS="."
			echo "Version of Sass found in your \$PATH is outdated. Please install Dart Sass >= ${minimum_segments[*]} to compile this theme."
		)
		exit 1
	fi
done

destination="${XDG_DATA_HOME:-"$HOME/.local/share"}/themes" # if $HOME is unset, you have bigger problems than this script not handling that
symlink=false

usage() {
	echo "$0: compile and install Ubuntu's Ambiance/Radiance themes"
	echo -e "\t-d, --destination    Path to install themes to"
	echo -e "\t-l, --symlink        Whether to create a symlink from the compiled output to the destination (useful for development)"
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		-d|--destination)
			if [[ $# -gt 1 ]]; then
				destination="$2"
			else
				echo "Passed \`$1\`, but did not specify a destination path" >&2
				usage
				exit 1
			fi
			shift 2
			;;
		-l|--symlink)
			symlink=true
			shift
			;;
		*)
			echo "Unknown argument: $1" >&2
			usage
			exit 1
			;;
	esac
done

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) # thank you to the ever-useful Stack Overflow!

# First let's compile the themes
(
	cd "$SCRIPT_DIR"
	if command_exists bun; then
		bun install
	elif command_exists pnpm; then
		pnpm install
	elif command_exists yarn; then
		yarn install
	elif command_exists npm; then
		npm install
	else
		# "Suitable" meaning one that happens to have been hard-coded
		# here, not necessarily that some other one I don't know about
		# wouldn't work
		echo "A suitable JavaScript package manager was not found in your \$PATH." >&2

		# I am not about to handle installing any of them
		# that's the user's problem
		echo "This is needed to install dependencies used in the Sass code - please install at least one of Bun, pnpm, Yarn or npm." >&2

		exit 1
	fi
)

rm -rf "$SCRIPT_DIR/dist" # work from a clean `dist`
sass --load-path "$SCRIPT_DIR/node_modules" --no-source-map "$SCRIPT_DIR/src:$SCRIPT_DIR/dist" # `--style=compressed` excludes closing semicolons in the last property of a rule, which GTK spams as a warning at runtime

# Now install them
alias put="cp -r"
if $symlink; then
	alias put="ln -s"
fi

for theme in Ambiance Radiance; do
	mkdir -p "$destination/$theme"

	rm -rf "$destination/$theme/gtk-4.0"
	mkdir "$destination/$theme/gtk-4.0"
	put "$SCRIPT_DIR/assets" "$destination/$theme/gtk-4.0/assets"

	put "$SCRIPT_DIR/dist/$theme/gtk-theme.css" "$destination/$theme/gtk-4.0/gtk.css"
done

prompt() {
	while
		printf "%s [Yn]: " "$1"
		read prompt_input || exit 1
		prompt=${prompt_input,,}
		[[ $prompt != "y" && $prompt != "n" && -n $prompt ]]
	do
		echo "Invalid input: \`$prompt_input\`. Please enter either nothing, a Y or an N." >&2
	done

	[[ $prompt = "y" || -z $prompt ]]
}

config=${XDG_CONFIG_HOME:-$HOME/.config}
if prompt "Would you like to apply app overrides? Some apps may not look correct without this. (Creates backup of, then sets \`$config/gtk-4.0\`)"; then
	if [[ -e "$config/gtk-4.0" ]]; then
		while
			# TOCTOU cannot truly be accounted for here,
			# but worth at least a check
			backup="$config/gtk-4.0.bak-$(date +'%Y-%m-%d-%T')"
			[[ -e "$backup" ]]
		do true; done

		echo "Backing up to $backup..."
		mv "$config/gtk-4.0" "$backup"
	fi

	if prompt "Would you like the Ambiance theme? Answer no if you prefer Radiance."; then
		theme=Ambiance
	else
		theme=Radiance
	fi
	mkdir -p "$config/gtk-4.0"
	put "$SCRIPT_DIR/assets" "$config/gtk-4.0/assets"
	put "$SCRIPT_DIR/dist/$theme/gtk-apps.css" "$config/gtk-4.0/gtk.css"
fi
