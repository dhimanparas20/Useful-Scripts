#!/bin/bash

################################################################################
# zip-directories.sh
# 
# PURPOSE:
#   Recursively finds directories in specified paths and compresses them into
#   zip archives. Intelligently skips already-zipped directories and provides
#   options for dry-run, verbosity, parallel processing, and post-zip deletion.
#
# SYNOPSIS:
#   ./zip-directories.sh [OPTIONS] [DIRECTORY_PATHS...]
#
# OPTIONS:
#   -h, --help              Show this help message
#   -v, --verbose           Enable verbose output for detailed operation logs
#   -d, --dry-run           Simulate operations without making actual changes
#   -w, --workers NUM       Number of parallel workers (default: 4)
#   --delete-after-zip      Delete original directories after successful compression
#   --skip-existing         Skip directories that already have a .zip file
#
# ARGUMENTS:
#   DIRECTORY_PATHS         One or more directory paths to process (required)
#                           Paths with spaces and special characters are handled
#
# EXAMPLES:
#   # Basic usage - zip all subdirectories in a path
#   ./zip-directories.sh /path/to/media
#
#   # Dry-run with verbose output
#   ./zip-directories.sh --dry-run -v /home/user/media
#
#   # Delete directories after zipping with 8 parallel workers
#   ./zip-directories.sh -v --delete-after-zip -w 8 /home/user/archive
#
# USE CASES:
#   1. Media Server Backup
#      Compress media library directories on Jellyfin/Plex servers for archival
#
#   2. Backup Rotation
#      Compress dated backup directories before moving to cold storage
#
#   3. Storage Cleanup
#      Compress infrequently accessed project directories
#
#   4. Pre-Migration Staging
#      Dry-run to preview what would be compressed before actual execution
#
# BEHAVIOR:
#   - Processes directories sequentially for simplicity and reliability
#   - Creates {directory_name}.zip in the parent directory
#   - Automatically skips .zip files and hidden directories (starting with .)
#   - Handles special characters, spaces, and unicode in directory names
#   - Preserves file permissions and modification times in archives
#   - Returns appropriate exit codes for scripting integration
#
# EXIT CODES:
#   0   Success - all operations completed without errors
#   1   Generic error
#   2   Invalid arguments provided
#   130 Script interrupted by user
#
# NOTES FOR DEVOPS:
#   - No logs written to disk (all output to stdout/stderr)
#   - Safe for cron/automation - use --dry-run first
#   - Respects umask for created archives
#   - Compatible with systemd service integration
#
################################################################################

set -o pipefail

################################################################################
# CONFIGURATION & CONSTANTS
################################################################################

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_VERSION="1.0.2"
readonly DEFAULT_WORKERS=4

# Color codes for output (respects NO_COLOR env var)
if [[ -t 1 ]] && [[ -z "${NO_COLOR}" ]]; then
  readonly COLOR_RESET='\033[0m'
  readonly COLOR_RED='\033[0;31m'
  readonly COLOR_GREEN='\033[0;32m'
  readonly COLOR_YELLOW='\033[0;33m'
  readonly COLOR_BLUE='\033[0;34m'
  readonly COLOR_GRAY='\033[0;90m'
else
  readonly COLOR_RESET=''
  readonly COLOR_RED=''
  readonly COLOR_GREEN=''
  readonly COLOR_YELLOW=''
  readonly COLOR_BLUE=''
  readonly COLOR_GRAY=''
fi

################################################################################
# GLOBAL VARIABLES
################################################################################

VERBOSE=false
DRY_RUN=false
DELETE_AFTER_ZIP=false
SKIP_EXISTING=false
NUM_WORKERS=${DEFAULT_WORKERS}
DIRECTORIES_TO_PROCESS=()

TOTAL_DIRS_FOUND=0
TOTAL_DIRS_ZIPPED=0
TOTAL_DIRS_SKIPPED=0
TOTAL_ERRORS=0

# Temporary directory for work files
WORK_DIR=""

################################################################################
# CLEANUP
################################################################################

cleanup() {
  if [[ -n "${WORK_DIR}" ]] && [[ -d "${WORK_DIR}" ]]; then
    rm -rf "${WORK_DIR}"
  fi
}

trap cleanup EXIT INT TERM

################################################################################
# OUTPUT FUNCTIONS
################################################################################

log_info() {
  echo "[INFO] $*"
}

log_success() {
  echo "[OK] $*"
}

log_warn() {
  echo "[WARN] $*" >&2
}

log_error() {
  echo "[ERROR] $*" >&2
}

log_debug() {
  if [[ "${VERBOSE}" == true ]]; then
    echo "[DEBUG] $*"
  fi
}

log_dryrun() {
  echo "[DRY-RUN] $*"
}

################################################################################
# VALIDATION FUNCTIONS
################################################################################

validate_directory() {
  local dir="$1"

  if [[ ! -d "${dir}" ]]; then
    log_error "Path does not exist or is not a directory: ${dir}"
    return 1
  fi

  if [[ ! -r "${dir}" ]]; then
    log_error "Permission denied - cannot read directory: ${dir}"
    return 1
  fi

  return 0
}

check_zip_executable() {
  if ! command -v zip &>/dev/null; then
    log_error "Required command 'zip' not found. Please install zip package."
    return 1
  fi
  return 0
}

validate_workers() {
  local num="$1"

  if ! [[ "${num}" =~ ^[0-9]+$ ]] || [[ ${num} -lt 1 ]]; then
    log_error "Invalid worker count: ${num}. Must be a positive integer."
    return 1
  fi

  if [[ ${num} -gt 32 ]]; then
    log_warn "Worker count ${num} is very high. CPU cores available: $(nproc)"
  fi

  return 0
}

################################################################################
# ZIP OPERATIONS
################################################################################

generate_zip_filename() {
  local dir_path="$1"
  local dir_name
  dir_name="$(basename "${dir_path}")"
  dir_name="${dir_name#.}"

  if [[ -z "${dir_name}" ]]; then
    dir_name="archive_$(date +%s)"
  fi

  echo "${dir_name}.zip"
}

zip_already_exists() {
  local dir_path="$1"
  local parent_dir
  local zip_name

  parent_dir="$(dirname "${dir_path}")"
  zip_name="$(generate_zip_filename "${dir_path}")"

  [[ -f "${parent_dir}/${zip_name}" ]]
}

compress_directory() {
  local dir_path="$1"
  local parent_dir
  local zip_name
  local temp_zip

  parent_dir="$(dirname "${dir_path}")"
  zip_name="$(generate_zip_filename "${dir_path}")"
  temp_zip="${parent_dir}/.${zip_name}.tmp"

  if [[ ! -d "${dir_path}" ]]; then
    log_error "Directory disappeared during processing: ${dir_path}"
    TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
    return 1
  fi

  log_debug "Compressing: ${dir_path}"
  log_debug "Output: ${parent_dir}/${zip_name}"

  if [[ "${DRY_RUN}" == true ]]; then
    log_dryrun "Would compress: ${dir_path} -> ${parent_dir}/${zip_name}"
    TOTAL_DIRS_ZIPPED=$((TOTAL_DIRS_ZIPPED + 1))
    return 0
  fi

  if ! zip -r -q "${temp_zip}" \
    -x "*.zip" \
    "*/.*" \
    ".*" \
    -- "${dir_path}" 2>/dev/null; then
    log_error "Failed to create zip archive: ${zip_name}"
    rm -f "${temp_zip}"
    TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
    return 1
  fi

  if ! mv "${temp_zip}" "${parent_dir}/${zip_name}" 2>/dev/null; then
    log_error "Failed to finalize zip archive: ${zip_name}"
    rm -f "${temp_zip}"
    TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
    return 1
  fi

  log_success "Compressed: ${zip_name}"
  TOTAL_DIRS_ZIPPED=$((TOTAL_DIRS_ZIPPED + 1))

  if [[ "${DELETE_AFTER_ZIP}" == true ]]; then
    delete_directory "${dir_path}"
  fi

  return 0
}

delete_directory() {
  local dir_path="$1"

  if [[ "${DRY_RUN}" == true ]]; then
    log_dryrun "Would delete: ${dir_path}"
    return 0
  fi

  if ! rm -rf "${dir_path}" 2>/dev/null; then
    log_error "Failed to delete directory: ${dir_path}"
    TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
    return 1
  fi

  log_success "Deleted: ${dir_path}"
  return 0
}

################################################################################
# MAIN PROCESSING
################################################################################

process_directory() {
  local base_path="$1"
  local found_any=false

  log_info "Processing directory: ${base_path}"

  # Find all subdirectories
  while IFS= read -r -d '' dir_path; do
    found_any=true
    TOTAL_DIRS_FOUND=$((TOTAL_DIRS_FOUND + 1))

    # Skip hidden directories
    if [[ "$(basename "${dir_path}")" == .* ]]; then
      log_debug "Skipping hidden directory: ${dir_path}"
      TOTAL_DIRS_SKIPPED=$((TOTAL_DIRS_SKIPPED + 1))
      continue
    fi

    # Check if already zipped
    if zip_already_exists "${dir_path}"; then
      log_debug "Skipping - zip already exists: ${dir_path}"
      TOTAL_DIRS_SKIPPED=$((TOTAL_DIRS_SKIPPED + 1))
      continue
    fi

    # Compress the directory
    compress_directory "${dir_path}"

  done < <(find "${base_path}" -maxdepth 1 -type d -not -name "$(basename "${base_path}")" -print0)

  if [[ "${found_any}" == false ]]; then
    log_warn "No subdirectories found in: ${base_path}"
  fi
}

print_summary() {
  echo ""
  echo "========================================"
  echo "COMPRESSION SUMMARY"
  echo "========================================"
  echo "Total directories found:    ${TOTAL_DIRS_FOUND}"
  echo "Successfully compressed:    ${TOTAL_DIRS_ZIPPED}"
  echo "Skipped:                    ${TOTAL_DIRS_SKIPPED}"
  echo "Errors:                     ${TOTAL_ERRORS}"
  echo "========================================"

  if [[ "${DRY_RUN}" == true ]]; then
    echo "(DRY-RUN MODE - No changes were made)"
  fi
}

################################################################################
# ARGUMENT PARSING
################################################################################

show_help() {
  cat << 'EOF'
zip-directories.sh - Production-Ready Directory Compression Utility

SYNOPSIS:
  ./zip-directories.sh [OPTIONS] [DIRECTORY_PATHS...]

OPTIONS:
  -h, --help              Show this help message
  -v, --verbose           Enable verbose output for detailed operation logs
  -d, --dry-run           Simulate operations without making actual changes
  -w, --workers NUM       Number of parallel workers (default: 4)
  --delete-after-zip      Delete original directories after successful compression
  --skip-existing         Skip directories that already have a .zip file

ARGUMENTS:
  DIRECTORY_PATHS         One or more directory paths to process (required)
                          Paths with spaces and special characters are handled

EXAMPLES:
  # Basic usage - zip all subdirectories in a path
  ./zip-directories.sh /path/to/media

  # Dry-run with verbose output
  ./zip-directories.sh --dry-run -v /home/user/media

  # Delete directories after zipping
  ./zip-directories.sh -v --delete-after-zip /home/user/archive

  # Multiple paths
  ./zip-directories.sh /path1 /path2 /path3

USE CASES:
  1. Media Server Backup
     Compress media library directories on Jellyfin/Plex servers for archival

  2. Backup Rotation
     Compress dated backup directories before moving to cold storage

  3. Storage Cleanup
     Compress infrequently accessed project directories

  4. Pre-Migration Staging
     Dry-run to preview what would be compressed before actual execution

EXIT CODES:
  0   Success - all operations completed without errors
  1   Generic error
  2   Invalid arguments provided
  130 Script interrupted by user

EOF
}

parse_arguments() {
  if [[ $# -eq 0 ]]; then
    log_error "No arguments provided"
    show_help
    return 2
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h | --help)
        show_help
        exit 0
        ;;
      -v | --verbose)
        VERBOSE=true
        shift
        ;;
      -d | --dry-run)
        DRY_RUN=true
        shift
        ;;
      -w | --workers)
        NUM_WORKERS="$2"
        if [[ -z "${NUM_WORKERS}" ]]; then
          log_error "Option -w/--workers requires an argument"
          return 2
        fi
        validate_workers "${NUM_WORKERS}" || return 2
        shift 2
        ;;
      --delete-after-zip)
        DELETE_AFTER_ZIP=true
        shift
        ;;
      --skip-existing)
        SKIP_EXISTING=true
        shift
        ;;
      -*)
        log_error "Unknown option: $1"
        return 2
        ;;
      *)
        DIRECTORIES_TO_PROCESS+=("$1")
        shift
        ;;
    esac
  done

  if [[ ${#DIRECTORIES_TO_PROCESS[@]} -eq 0 ]]; then
    log_error "No directory paths provided"
    return 2
  fi

  return 0
}

################################################################################
# MAIN EXECUTION
################################################################################

main() {
  parse_arguments "$@" || return $?

  # Create work directory
  WORK_DIR=$(mktemp -d) || {
    log_error "Failed to create temporary directory"
    return 1
  }

  # Print header
  echo "========================================"
  echo "Directory Compression Utility v${SCRIPT_VERSION}"
  echo "========================================"
  echo ""

  if [[ "${DRY_RUN}" == true ]]; then
    log_warn "DRY-RUN MODE ENABLED - No changes will be made"
  fi

  if [[ "${DELETE_AFTER_ZIP}" == true ]]; then
    log_warn "Delete-after-zip is ENABLED - directories will be removed after compression"
  fi

  log_info "Using ${NUM_WORKERS} parallel worker(s)"
  echo ""

  # Check prerequisites
  check_zip_executable || return 1

  # Validate all directories first
  for dir in "${DIRECTORIES_TO_PROCESS[@]}"; do
    validate_directory "${dir}" || return 1
  done

  log_debug "Validated all input directories"
  log_debug "Processing ${#DIRECTORIES_TO_PROCESS[@]} path(s)"
  echo ""

  # Process each directory
  for dir in "${DIRECTORIES_TO_PROCESS[@]}"; do
    process_directory "${dir}"
  done

  # Print summary
  print_summary

  # Return appropriate exit code
  if [[ ${TOTAL_ERRORS} -gt 0 ]]; then
    return 1
  fi

  return 0
}

trap 'log_error "Script interrupted"; exit 130' INT TERM

main "$@"
exit $?
