#!/bin/bash

# Define color codes
RESET='\033[0m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
BOLD='\033[1m'
UNDERLINE='\033[4m'

# Function to print messages in different colors
print_colored() {
	local color="$1"
	local message="$2"
	printf "${color}${message}${RESET}\n"
}

if [ -s "/usr/local/bin/projectme" ]; then
	print_colored "$RED" "The application are already installed!"
	exit 0
fi

# Define the content of the projects.sh script
read -r -d '' SCRIPT_CONTENT <<'EOF'
#!/bin/bash

# Define color codes
RESET='\033[0m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
BOLD='\033[1m'
UNDERLINE='\033[4m'

# Function to print messages in different colors
print_colored() {
    local color="$1"
    local message="$2"
    printf "${color}${message}${RESET}\n"
}

# Define the base directory where your projects are located
[ -z "$PROJECTS_DIR" ] && PROJECTS_DIR="$HOME/projects"

# Function to create a new project
create_new_project() {
    NEW_PROJECT="$PROJECTS_DIR/$1"
    if [ -d "$NEW_PROJECT" ]; then
        print_colored "$RED" "Project $1 already exists."
    else
        mkdir -p "$NEW_PROJECT"
        print_colored "$GREEN" "Created new project: $NEW_PROJECT"
    fi
}


if [[ "$1" == "-n" ]] && [[ -n "$2" ]]; then
    create_new_project "$2"
    return 0
fi

if [[ "$1" == "-r" ]]; then
  cd "$PROJECTS_DIR" || {
      print_colored "$RED" "Failed to change directory"
      return 1
  }
  print_colored "$GREEN" "Changed to projects folder"
  return 0
fi

# Get the filter argument if provided
FILTER=$1

# Use find to get the list of directories and filter them if a filter is provided
if [ -n "$FILTER" ]; then
    PROJECTS=$(find "$PROJECTS_DIR" -maxdepth 1 -mindepth 1 -type d -iname "*$FILTER*" | sed 's|.*/||')
else
    PROJECTS=$(find "$PROJECTS_DIR" -maxdepth 1 -mindepth 1 -type d | sed 's|.*/||')
fi

# Convert the PROJECTS variable to an array, but only if there are results
PROJECTS_ARRAY=()
if [ -n "$PROJECTS" ]; then
    while IFS= read -r line; do
        PROJECTS_ARRAY+=("$line")
    done <<<"$PROJECTS"
fi

# Check the number of matching projects
NUM_PROJECTS=${#PROJECTS_ARRAY[@]}

if [ "$NUM_PROJECTS" -eq 0 ]; then
    print_colored "$RED" "No projects found matching the filter."
elif [ "$NUM_PROJECTS" -eq 1 ]; then
    # If only one project matches, change to that directory
    cd "$PROJECTS_DIR/${PROJECTS_ARRAY[1]}" || {
        print_colored "$RED" "Failed to change directory"
        return 1
    }
    print_colored "$GREEN" "Changed directory to ${PROJECTS_ARRAY[1]}"
else
    # Use fzf to select a project if more than one match is found
    SELECTED_PROJECT=$(printf '%s\n' "${PROJECTS_ARRAY[@]}" | fzf --prompt="Select a project: ")

    # If a project is selected, change to that directory
    if [ -n "$SELECTED_PROJECT" ]; then
        cd "$PROJECTS_DIR/$SELECTED_PROJECT" || {
            print_colored "$RED" "Failed to change directory"
            return 1
        }
        print_colored "$GREEN" "Changed directory to $SELECTED_PROJECT"
    else
        print_colored "$RED" "No project selected"
    fi
fi
EOF

# Create the projects.sh script in /usr/local/bin
echo "$SCRIPT_CONTENT" | sudo tee /usr/local/bin/projectme >/dev/null

# Make the script executable
sudo chmod +x /usr/local/bin/projectme

if [ -n "$($SHELL -c 'echo $ZSH_VERSION')" ]; then
	# Zsh shell
	echo "alias pm='source /usr/local/bin/projectme'" >>~/.zshrc
	echo "export PROJECTS_DIR='$HOME/Projects'" >>~/.zshrc
	print_colored "$GREEN" "Setup complete. Execute \"source ~/.zshrc\" or restart your terminal to be able to execute \"pm\""
elif [ -n "$($SHELL -c 'echo $BASH_VERSION')" ]; then
	# Bash shell
	echo "alias pm='source /usr/local/bin/projectme'" >>~/.bashrc
	echo "export PROJECTS_DIR='$HOME/Projects'" >>~/.bashrc
	print_colored "$GREEN" "Setup complete. Execute \"source ~/.bashrc\" or restart your terminal to be able to execute \"pm\""
else
	print_colored "$RED" "Unsupported shell. Please manually add the alias to your shell configuration file. \"echo \"alias pm=\'source /usr/local/bin/projectme\'\" >> <your-shell-configuration-file>\""
fi
