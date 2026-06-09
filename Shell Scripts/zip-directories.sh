#!/usr/bin/env bash

###############################################################################
# SCRIPT NAME:  zip-directories.sh
# DESCRIPTION:  Production-grade script to recursively zip subdirectories.
#               It traverses specified paths, finds directories, and zips them
#               into individual archives (e.g., my_folder.zip), skipping any
#               that already have a corresponding .zip file.
#
# AUTHOR:       Paras Dhiman
# VERSION:      1.0.0
# DATE:         2026-06-09
###############################################################################

set -euo pipefail

# =============================================================================
# CONFIGURATION & DEFAULTS
# =============================================================================

# Default configuration
DRY_RUN=false
LOG_FILE=""
VERBOSE=false
COMPRESSION_LEVEL=6          # 1-9 (Low to High compression)
EXCLUDE_PATTERNS=()          # Array of patterns to exclude (e.g., "*/tmp/*")
PATHS=()                     # List of paths to process

# =============================================================================
# FUNCTIONS
# =============================================================================

# Show help documentation (includes README)
usage() {
    cat <<EOF
NAME
    zip-directories.sh - Batch zip directories within specific paths.

SYNOPSIS
    zip-directories.sh [OPTIONS] PATH1 [PATH2 ...]

DESCRIPTION
    This script accepts one or more file system paths. It scans these paths
    for subdirectories and creates a zip archive for each directory found.
    
    If a .zip file with the same name as the directory already exists in
    the parent directory, the script automatically ignores that directory.
    
    This is useful for batch archiving, backups, or organizing large
    datasets where subdirectories need to be compressed individually.

OPTIONS
    -d, --dry-run           
        Simulate the process. Shows what would be zipped without actually
        creating any files. Useful for testing.

    -l, --log FILE          
        Enable file logging. All output will be written to the specified file.

    -v, --verbose           
        Enable verbose output. Displays detailed status for every operation.

    -c, --compression LEVEL
        Set compression level (1-9). 
        Default: 6
        1 = Fastest (Less compression)
        9 = Best (Most compression)

    -e, --exclude PATTERN   
        Exclude directories matching the shell pattern.
        Can be used multiple times.
        Example: -e "*/node_modules/*" -e "*/tmp/*"

    -h, --help              
        Display this help message and exit.

EXAMPLES
    # Basic usage with a single path
    ./zip-directories.sh /var/log

    # Multiple paths
    ./zip-directories.sh /home/user/documents /home/user/projects

    # Dry run with verbose output (Safe testing)
    ./zip-directories.sh -d -v /data/media

    # High compression, ignoring node_modules and cache folders
    ./zip-directories.sh -c 9 -e "*/node_modules/*" -e "*/cache/*" /opt/apps

    # Logging to a file
    ./zip-directories.sh -l /var/log/zip_activity.log /backup/root

    # Running with default configured paths (no arguments)
    ./zip-directories.sh

NOTES
    - The script uses 'realpath' to resolve paths safely.
    - Permissions are checked before attempting to write zip files.
    - The script preserves directory hierarchy inside the zip file.

EXIT CODES
    0   Success
    1   General Error (Missing dependencies, invalid paths, etc.)
    2   Permission Error

EOF
    exit 0
}

# Custom logger that handles file and console output
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Format: [TIMESTAMP] [LEVEL] Message
    local formatted_msg="[${timestamp}] [${level}] ${message}"
    
    # Output to console
    if [[ "${VERBOSE}" == true ]] || [[ "${level}" == "ERROR" ]] || [[ "${level}" == "WARNING" ]] || [[ "${level}" == "START" ]]; then
        echo "${formatted_msg}" >&2
    fi
    
    # Output to log file if specified
    if [[ -n "${LOG_FILE}" ]]; then
        echo "${formatted_msg}" >> "${LOG_FILE}"
    fi
}

# Check for required system commands
check_dependencies() {
    local deps=("zip" "find" "realpath")
    for dep in "${deps[@]}"; do
        if ! command -v "${dep}" &>/dev/null; then
            log "ERROR" "Required command '${dep}' is missing."
            exit 1
        fi
    done
}

# Parse command line arguments
parse_args() {
    local args=()
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -l|--log)
                if [[ -z "${2:-}" ]]; then
                    log "ERROR" "Option $1 requires a filename argument."
                    exit 1
                fi
                LOG_FILE="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -c|--compression)
                if [[ -z "${2:-}" ]] || ! [[ "${2}" =~ ^[1-9]$ ]]; then
                    log "ERROR" "Option $1 requires a digit between 1 and 9."
                    exit 1
                fi
                COMPRESSION_LEVEL="$2"
                shift 2
                ;;
            -e|--exclude)
                if [[ -z "${2:-}" ]]; then
                    log "ERROR" "Option $1 requires a pattern string."
                    exit 1
                fi
                EXCLUDE_PATTERNS+=("${2}")
                shift 2
                ;;
            -h|--help)
                usage
                ;;
            -*)
                log "ERROR" "Unknown option: $1. Use --help for usage."
                exit 1
                ;;
            *)
                args+=("$1")
                shift
                ;;
        esac
    done
    
    # Handle input paths
    if [[ ${#args[@]} -gt 0 ]]; then
        PATHS=("${args[@]}")
    else
        # ============================================================================
        # DEFAULT PATHS CONFIGURATION
        # If no arguments are passed, the script processes these paths:
        # ============================================================================
        PATHS=(
            # "/path/to/default/folder/1"
            # "/path/to/default/folder/2"
        )

        if [[ ${#PATHS[@]} -eq 0 ]]; then
            log "WARNING" "No paths provided and no default paths configured."
            usage
        else
            log "INFO" "No arguments provided. Using internal configuration paths."
        fi
    fi
}

# Validate that paths exist and are readable
validate_paths() {
    for p in "${PATHS[@]}"; do
        # Use realpath to normalize the path
        local clean_path
        clean_path=$(realpath -e "$p" 2>/dev/null) || {
            log "ERROR" "Path does not exist or cannot be accessed: $p"
            exit 1
        }
        # Replace original with normalized path
        p="$clean_path"
    done
}

# Check exclusion patterns
is_excluded() {
    local dir_path="$1"
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        # Using bash pattern matching
        if [[ "${dir_path}" == ${pattern} ]]; then
            return 0 # True, it is excluded
        fi
    done
    return 1 # False, not excluded
}

# Core logic to zip a specific directory
zip_directory() {
    local target_dir="$1"
    local dir_name
    local parent_dir
    local zip_file_name
    local zip_full_path
    
    # Extract names
    dir_name=$(basename "${target_dir}")
    parent_dir=$(dirname "${target_dir}")
    zip_file_name="${dir_name}.zip"
    zip_full_path="${parent_dir}/${zip_file_name}"

    # 1. Check Exclusions
    if is_excluded "${target_dir}"; then
        log "INFO" "Skipping (Excluded): ${target_dir}"
        return 0
    fi

    # 2. Check Existing Zips
    if [[ -f "${zip_full_path}" ]]; then
        log "INFO" "Skipping (Exists): ${zip_full_path}"
        return 0
    fi

    # 3. Check Write Permissions
    if [[ ! -w "${parent_dir}" ]]; then
        log "ERROR" "Permission Denied: Cannot write to ${parent_dir}"
        return 1
    fi

    log "INFO" "Zipping: ${target_dir} -> ${zip_full_path}"
    
    # Dry Run Logic
    if [[ "${DRY_RUN}" == true ]]; then
        log "DRY_RUN" "Action: Would create ${zip_full_path}"
        return 0
    fi

    # Execute Zip
    # We cd into the parent directory to ensure the zip file root is just the folder name
    (
        cd "${parent_dir}" || exit 1
        zip -r -"${COMPRESSION_LEVEL}" "${zip_file_name}" "${dir_name}" > /dev/null 2>&1
    )

    if [[ $? -eq 0 ]]; then
        log "SUCCESS" "Created: ${zip_full_path} ($(du -h "${zip_full_path}" | cut -f1))"
        return 0
    else
        log "ERROR" "Failed to zip: ${target_dir}"
        return 1
    fi
}

# Main execution loop
process_paths() {
    local error_count=0
    local processed_count=0

    for path in "${PATHS[@]}"; do
        log "INFO" "Scanning directory: ${path}"
        
        # Find directories only (-maxdepth 1 to avoid recursion into subdirs)
        # We process immediate children of the path provided
        while IFS= read -r -d '' dir; do
            if zip_directory "${dir}"; then
                ((processed_count++))
            else
                ((error_count++))
            fi
        done < <(find "${path}" -maxdepth 1 -mindepth 1 -type d -print0)
    done

    log "INFO" "----------------------------------------"
    log "INFO" "SUMMARY: Processed ${processed_count} directories. Errors: ${error_count}"
}

# Entry Point
main() {
    parse_args "$@"
    check_dependencies
    validate_paths
    
    log "START" "Initializing Zip Process..."
    process_paths
    log "START" "Script finished."
}

# Run
main "$@"
