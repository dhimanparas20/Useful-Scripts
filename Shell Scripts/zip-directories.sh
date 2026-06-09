#!/usr/bin/env bash

###############################################################################
# SCRIPT NAME:  zip-directories.sh
# DESCRIPTION:  Production-grade script to recursively zip subdirectories.
#               It traverses specified paths, finds directories, and zips them
#               into individual archives (e.g., my_folder.zip), skipping any
#               that already have a corresponding .zip file.
#
# AUTHOR:       T3 Chat
# VERSION:      1.1.0
# DATE:         2026-06-09
###############################################################################

set -euo pipefail

# =============================================================================
# CONFIGURATION & DEFAULTS
# =============================================================================

DRY_RUN=false
LOG_FILE=""
VERBOSE=false
DELETE_AFTER_ZIP=false
COMPRESSION_LEVEL=6
EXCLUDE_PATTERNS=()
PATHS=()

# =============================================================================
# FUNCTIONS
# =============================================================================

usage() {
    cat <<EOF
NAME
    zip-directories.sh - Batch zip subdirectories with optional cleanup.

SYNOPSIS
    zip-directories.sh [OPTIONS] PATH1 [PATH2 ...]

DESCRIPTION
    This script scans specified paths for immediate subdirectories and
    creates a zip archive for each one. If a .zip file already exists,
    the directory is skipped. Optionally, the source directory can be
    deleted after a successful zip.

OPTIONS
    -d, --dry-run           
        Simulate the process. Show what would be done without changes.

    -l, --log FILE          
        Enable file logging to the specified file.

    -v, --verbose           
        Enable verbose console output.

    -c, --compression LEVEL
        Compression level 1-9. Default: 6.

    -e, --exclude PATTERN   
        Exclude directories matching the pattern.
        Can be repeated: -e "*/tmp/*"

    --delete-after-zip      
        Delete the source directory AFTER a successful zip.
        Default: Do NOT delete.

    -h, --help              
        Display this help message and exit.

EXAMPLES
    # Zip everything, verbose output
    ./zip-directories.sh -v /data/Games /data/Others

    # Zip and delete originals
    ./zip-directories.sh --delete-after-zip /data/Games

    # Dry run with deletion (safe preview)
    ./zip-directories.sh -d --delete-after-zip /data/Games

    # Every 4 hours via cron (delete originals):
    # 0 */4 * * * /path/to/zip-directories.sh --delete-after-zip /data/Games /data/Others

CRON EXAMPLE (runs every 4 hours)
    0 */4 * * * /home/ubuntu/jellyfin_mirror_server/zip-directories.sh \\
        -v --delete-after-zip \\
        /home/ubuntu/jellyfin_mirror_server/data/Games \\
        /home/ubuntu/jellyfin_mirror_server/data/Others \\
        /home/ubuntu/jellyfin_mirror_server/data/Streaming/Anime \\
        /home/ubuntu/jellyfin_mirror_server/data/Streaming/Movies \\
        /home/ubuntu/jellyfin_mirror_server/data/Streaming/Series \\
        >> /home/ubuntu/jellyfin_mirror_server/logs/cron.log 2>&1

EOF
    exit 0
}

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local formatted_msg="[${timestamp}] [${level}] ${message}"

    if [[ "${VERBOSE}" == true ]] || [[ "${level}" == "ERROR" ]] || [[ "${level}" == "WARNING" ]] || [[ "${level}" == "START" ]]; then
        echo "${formatted_msg}" >&2
    fi

    if [[ -n "${LOG_FILE}" ]]; then
        echo "${formatted_msg}" >> "${LOG_FILE}"
    fi
}

check_dependencies() {
    local deps=("zip" "find" "realpath")
    for dep in "${deps[@]}"; do
        if ! command -v "${dep}" &>/dev/null; then
            log "ERROR" "Required command '${dep}' is missing."
            exit 1
        fi
    done
}

parse_args() {
    local args=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -l|--log)
                [[ -z "${2:-}" ]] && { log "ERROR" "$1 requires a filename."; exit 1; }
                LOG_FILE="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -c|--compression)
                [[ -z "${2:-}" ]] && { log "ERROR" "$1 requires 1-9."; exit 1; }
                if ! [[ "${2}" =~ ^[1-9]$ ]]; then
                    log "ERROR" "Compression must be 1-9, got: ${2}"
                    exit 1
                fi
                COMPRESSION_LEVEL="$2"
                shift 2
                ;;
            -e|--exclude)
                [[ -z "${2:-}" ]] && { log "ERROR" "$1 requires a pattern."; exit 1; }
                EXCLUDE_PATTERNS+=("${2}")
                shift 2
                ;;
            --delete-after-zip)
                DELETE_AFTER_ZIP=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            -*)
                log "ERROR" "Unknown option: $1"
                usage
                ;;
            *)
                args+=("$1")
                shift
                ;;
        esac
    done

    if [[ ${#args[@]} -eq 0 ]]; then
        PATHS=(
            # "/home/ubuntu/jellyfin_mirror_server/data/Games"
            # "/home/ubuntu/jellyfin_mirror_server/data/Others"
        )
        if [[ ${#PATHS[@]} -eq 0 ]]; then
            log "WARNING" "No paths provided and no defaults configured."
            usage
        else
            log "INFO" "Using configured default paths."
        fi
    else
        PATHS=("${args[@]}")
    fi
}

validate_paths() {
    for p in "${PATHS[@]}"; do
        if [[ ! -d "${p}" ]]; then
            log "ERROR" "Path does not exist: ${p}"
            exit 1
        fi
        if [[ ! -r "${p}" ]]; then
            log "ERROR" "No read permission: ${p}"
            exit 1
        fi
    done
}

is_excluded() {
    local dir_path="$1"
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        if [[ "${dir_path}" == ${pattern} ]]; then
            return 0
        fi
    done
    return 1
}

zip_directory() {
    local target_dir="$1"
    local dir_name
    local parent_dir
    local zip_file_name
    local zip_full_path

    dir_name=$(basename "${target_dir}")
    parent_dir=$(dirname "${target_dir}")
    zip_file_name="${dir_name}.zip"
    zip_full_path="${parent_dir}/${zip_file_name}"

    # 1. Check exclusions
    if is_excluded "${target_dir}"; then
        log "INFO" "Skipping (Excluded): ${target_dir}"
        return 0
    fi

    # 2. Check existing zip
    if [[ -f "${zip_full_path}" ]]; then
        log "INFO" "Skipping (Exists): ${zip_full_path}"
        return 0
    fi

    # 3. Check write permissions
    if [[ ! -w "${parent_dir}" ]]; then
        log "ERROR" "Permission Denied: Cannot write to ${parent_dir}"
        return 1
    fi

    log "INFO" "Zipping: ${target_dir} -> ${zip_full_path}"

    if [[ "${DRY_RUN}" == true ]]; then
        log "DRY_RUN" "Action: Would create ${zip_full_path}"
        if [[ "${DELETE_AFTER_ZIP}" == true ]]; then
            log "DRY_RUN" "Action: Would DELETE ${target_dir}"
        fi
        return 0
    fi

    # Create zip using subshell to cd into parent
    (
        cd "${parent_dir}" || exit 1
        zip -r -"${COMPRESSION_LEVEL}" "${zip_file_name}" "${dir_name}" > /dev/null 2>&1
    )
    local zip_status=$?

    if [[ ${zip_status} -eq 0 ]]; then
        log "SUCCESS" "Created: ${zip_full_path} ($(du -h "${zip_full_path}" | cut -f1))"

        # Delete source if requested
        if [[ "${DELETE_AFTER_ZIP}" == true ]]; then
            log "INFO" "Deleting source: ${target_dir}"
            rm -rf "${target_dir}"
            if [[ $? -eq 0 ]]; then
                log "SUCCESS" "Deleted: ${target_dir}"
            else
                log "ERROR" "Failed to delete: ${target_dir}"
                return 1
            fi
        fi
        return 0
    else
        log "ERROR" "Failed to zip: ${target_dir}"
        return 1
    fi
}

process_paths() {
    local error_count=0
    local processed_count=0

    for path in "${PATHS[@]}"; do
        log "INFO" "Scanning: ${path}"
        while IFS= read -r -d '' dir; do
            if zip_directory "${dir}"; then
                ((processed_count++))
            else
                ((error_count++))
            fi
        done < <(find "${path}" -maxdepth 1 -mindepth 1 -type d -print0)
    done

    log "INFO" "========================================"
    log "INFO" "SUMMARY: Processed ${processed_count} directories, Errors ${error_count}"
    log "INFO" "========================================"
}

main() {
    parse_args "$@"
    check_dependencies
    validate_paths
    log "START" "Zip process initialized."
    process_paths
    log "START" "Zip process finished."
}

main "$@"
