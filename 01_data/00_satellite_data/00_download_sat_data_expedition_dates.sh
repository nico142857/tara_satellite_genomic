#!/bin/bash
#SBATCH --job-name=Download
#SBATCH --partition=general
#SBATCH --output=logs/dwn.%a.%N.%j.out
#SBATCH --error=logs/dwn.%a.%N.%j.err
##SBATCH --mail-user=
##SBATCH --mail-type=ALL
#SBATCH -n 1 # number of jobs
#SBATCH -c 1 # number of cpu
##SBATCH --array=1-24
#SBATCH --mem=1G

# email and password for authentication
USER_EMAIL="nicostarr98@gmail.com"
PASSWORD="$WGET_PASSWORD"  # Ensure $WGET_PASSWORD is exported in your environment

DATES_FILE="unique_dates_yyyymmdd.tsv"


mapfile -t DATES < <(tail -n +2 "$DATES_FILE") # Read the dates into an array, skipping the header line

# Define the features in an array
FEATURES=(
    "CHL.chlor_a" "FLH.nflh" "FLH.ipar" "IOP.adg_unc_443" "IOP.adg_443" "IOP.aph_unc_443" "IOP.aph_443"
    "IOP.bbp_s" "IOP.adg_s" "IOP.bbp_unc_443" "IOP.bbp_443" "IOP.a_412" "IOP.a_443" "IOP.a_469"
    "IOP.a_488" "IOP.a_531" "IOP.a_547" "IOP.a_555" "IOP.a_645" "IOP.a_667" "IOP.a_678" "IOP.bb_412"
    "IOP.bb_443" "IOP.bb_469" "IOP.bb_488" "IOP.bb_531" "IOP.bb_547" "IOP.bb_555" "IOP.bb_645"
    "IOP.bb_667" "IOP.bb_678" "KD.Kd_490" "NSST.sst" "PAR.par" "PIC.pic" "POC.poc" "RRS.aot_869"
    "RRS.angstrom" "RRS.Rrs_412" "RRS.Rrs_443" "RRS.Rrs_469" "RRS.Rrs_488" "RRS.Rrs_531" "RRS.Rrs_547"
    "RRS.Rrs_555" "RRS.Rrs_645" "RRS.Rrs_667" "RRS.Rrs_678" "SST.sst"
)

# resolution
RESOLUTION="9km"

BASE_URL="https://oceandata.sci.gsfc.nasa.gov/cgi/getfile"

for DATE in "${DATES[@]}"; do
    # extract year, month, and calculate end date of the month
    YEAR_MONTH=$(echo "$DATE" | cut -c1-6)
    START_DATE="$DATE"
    END_DATE=$(date -d "$START_DATE +1 month -1 day" +"%Y%m%d")

    for FEATURE in "${FEATURES[@]}"; do
        for SATELLITE in "AQUA_MODIS" "TERRA_MODIS"; do
            FILE_NAME="${SATELLITE}.${START_DATE}_${END_DATE}.L3m.MO.${FEATURE}.${RESOLUTION}.nc"
            URL="${BASE_URL}/${FILE_NAME}"
            if [ ! -f "$FILE_NAME" ]; then
                echo "Downloading $FILE_NAME..."
                wget --user="$USER_EMAIL" --password="$PASSWORD" --auth-no-challenge=on "$URL"
            else
                echo "File $FILE_NAME already exists. Skipping download."
            fi
        done
    done
done