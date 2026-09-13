#!/usr/bin/env bash

set -euo pipefail

script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
data_directory="${script_directory}/../Data"
force_download=false
include_de441=true

usage() {
    cat <<'EOF'
Usage: bootstrap-astronomy-data.sh [--force] [--skip-de441]

Downloads the source catalogues used to generate Calendars astronomy tables.
Files are placed under Packages/Calendars/Data using the layout expected by
the generator. Existing files are left untouched unless --force is supplied.

Options:
  --force       Download and replace files that already exist.
  --skip-de441  Skip the multi-gigabyte JPL DE441 ephemeris download.
  -h, --help    Show this help.
EOF
}

while (($#)); do
    case "$1" in
        --force)
            force_download=true
            ;;
        --skip-de441)
            include_de441=false
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

for command_name in curl gzip; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Required command not found: $command_name" >&2
        exit 1
    fi
done

download_file() {
    local source_url="$1"
    local destination="$2"

    if [[ -f "$destination" && "$force_download" == false ]]; then
        echo "Already present: ${destination#"${data_directory}/"}"
        return
    fi

    mkdir -p "$(dirname "$destination")"
    local partial_file="${destination}.download"
    echo "Downloading: ${destination#"${data_directory}/"}"
    curl --fail --location --retry 3 --continue-at - \
        --output "$partial_file" "$source_url"
    mv "$partial_file" "$destination"
}

download_gzip() {
    local source_url="$1"
    local destination="$2"

    if [[ -f "$destination" && "$force_download" == false ]]; then
        echo "Already present: ${destination#"${data_directory}/"}"
        return
    fi

    mkdir -p "$(dirname "$destination")"
    local archive_file="${destination}.gz.download"
    local expanded_file="${destination}.download"
    echo "Downloading: ${destination#"${data_directory}/"}"
    curl --fail --location --retry 3 --continue-at - \
        --output "$archive_file" "$source_url"
    gzip --decompress --stdout "$archive_file" > "$expanded_file"
    mv "$expanded_file" "$destination"
    rm "$archive_file"
}

cds_base_url="https://cdsarc.cds.unistra.fr/ftp"

download_file \
    "${cds_base_url}/V/50/ReadMe" \
    "${data_directory}/YBSC5/readme.txt"
download_gzip \
    "${cds_base_url}/V/50/catalog.gz" \
    "${data_directory}/YBSC5/catalog"
download_gzip \
    "${cds_base_url}/V/50/notes.gz" \
    "${data_directory}/YBSC5/notes"

download_file \
    "${cds_base_url}/I/239/ReadMe" \
    "${data_directory}/Hipparcos-I-239/ReadMe.txt"
download_gzip \
    "${cds_base_url}/I/239/hip_main.dat.gz" \
    "${data_directory}/Hipparcos-I-239/hip_main.dat"

download_file \
    "${cds_base_url}/I/311/ReadMe" \
    "${data_directory}/Hipparcos-2-CDS/ReadMe.txt"
download_gzip \
    "${cds_base_url}/I/311/hip2.dat.gz" \
    "${data_directory}/Hipparcos-2-CDS/hip2.dat"

nasa_eclipse_url="https://eclipse.gsfc.nasa.gov"
download_file \
    "${nasa_eclipse_url}/5MCSE/5MKSEcatalog.txt" \
    "${data_directory}/NASA-Eclipses/5MKSEcatalog.txt"
download_file \
    "${nasa_eclipse_url}/eclipse_besselian_from_mysqldump2.csv" \
    "${data_directory}/NASA-Eclipses/solar-eclipse-besselian.csv"

if [[ "$include_de441" == true ]]; then
    jpl_linux_url="https://ssd.jpl.nasa.gov/ftp/eph/planets/Linux/de441"
    jpl_ascii_url="https://ssd.jpl.nasa.gov/ftp/eph/planets/ascii/de441"

    download_file \
        "${jpl_linux_url}/linux_m13000p17000.441" \
        "${data_directory}/DE441/linux_m13000p17000.441"
    download_file \
        "${jpl_ascii_url}/header.441" \
        "${data_directory}/DE441/header.441"
    download_file \
        "${jpl_ascii_url}/testpo.441" \
        "${data_directory}/DE441/testpo.441"
fi

echo "Astronomy source data is ready in ${data_directory}"
