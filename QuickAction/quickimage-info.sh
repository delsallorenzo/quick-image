#!/bin/zsh
# QuickImage Info — Quick Action for macOS
# Shows detailed image metadata (dimensions, DPI, color profile, bit depth,
# format, EXIF) for the selected image file(s) using only native macOS tools.
#
# Used as the shell body of an Automator "Quick Action" (Service) that
# receives image files in Finder. Receives file paths as arguments.

emulate -L zsh
setopt no_nomatch

# ---- helpers ---------------------------------------------------------------

# Read a single field from `sips -g all` output.
sips_field() {
    # $1 = full sips output, $2 = key
    print -r -- "$1" | awk -v k="$2" '$1 == k":" { $1=""; sub(/^ /,""); print; exit }'
}

# Read a single mdls attribute (returns empty if (null)).
mdls_field() {
    # $1 = file, $2 = attribute
    local v
    v=$(mdls -raw -name "$2" "$1" 2>/dev/null)
    [[ "$v" == "(null)" ]] && v=""
    print -r -- "$v"
}

human_size() {
    # $1 = bytes
    local b=$1
    if (( b < 1024 )); then
        print -r -- "${b} B"
    elif (( b < 1048576 )); then
        printf '%.0f KB\n' $(( b / 1024.0 ))
    elif (( b < 1073741824 )); then
        printf '%.2f MB\n' $(( b / 1048576.0 ))
    else
        printf '%.2f GB\n' $(( b / 1073741824.0 ))
    fi
}

friendly_color() {
    # Map raw profile/space to a friendly label.
    local p="$1" s="$2" l
    l="${p:l}"
    case "$l" in
        *display\ p3*)  print -r -- "Display P3"; return ;;
        *prophoto*)     print -r -- "ProPhoto RGB"; return ;;
        *adobe\ rgb*)   print -r -- "Adobe RGB"; return ;;
        *srgb*)         print -r -- "sRGB"; return ;;
        *p3*)           print -r -- "P3"; return ;;
        *gray*)         print -r -- "Grayscale"; return ;;
        *cmyk*)         print -r -- "CMYK"; return ;;
    esac
    [[ -n "$p" ]] && { print -r -- "$p"; return; }
    case "$s" in
        RGB)  print -r -- "RGB" ;;
        CMYK) print -r -- "CMYK" ;;
        GRAY|Gray) print -r -- "Grayscale" ;;
        *) print -r -- "${s:-Unknown}" ;;
    esac
}

# ---- build report for one file --------------------------------------------

describe() {
    local f="$1"
    local name="${f:t}"
    local all w h dw dh bps spp alpha space profile fmt
    all=$(sips -g all "$f" 2>/dev/null)

    w=$(sips_field "$all" pixelWidth)
    h=$(sips_field "$all" pixelHeight)
    dw=$(sips_field "$all" dpiWidth)
    dh=$(sips_field "$all" dpiHeight)
    bps=$(sips_field "$all" bitsPerSample)
    spp=$(sips_field "$all" samplesPerPixel)
    alpha=$(sips_field "$all" hasAlpha)
    space=$(sips_field "$all" space)
    profile=$(sips_field "$all" profile)
    fmt=$(sips_field "$all" format)

    local bytes size
    bytes=$(stat -f%z "$f" 2>/dev/null)
    size=$(human_size ${bytes:-0})

    local dpi
    dw=${dw%%.*}; dh=${dh%%.*}
    if [[ "$dw" == "$dh" ]]; then dpi="${dw:-72} dpi"; else dpi="${dw} × ${dh} dpi"; fi

    local depth="${bps:-8}-bit"
    [[ -n "$spp" ]] && depth="$depth · $spp ch"
    [[ "$alpha" == "yes" ]] && depth="$depth + α"

    local color
    color=$(friendly_color "$profile" "$space")

    # EXIF via Spotlight metadata
    local make model lens created iso fnum exp focal
    make=$(mdls_field "$f" kMDItemAcquisitionMake)
    model=$(mdls_field "$f" kMDItemAcquisitionModel)
    lens=$(mdls_field "$f" kMDItemLensModel)
    created=$(mdls_field "$f" kMDItemContentCreationDate)
    iso=$(mdls_field "$f" kMDItemISOSpeed)
    fnum=$(mdls_field "$f" kMDItemFNumber)
    exp=$(mdls_field "$f" kMDItemExposureTimeSeconds)
    focal=$(mdls_field "$f" kMDItemFocalLength)

    local out="📷  ${name}
────────────────────────
Size:     ${w:-?} × ${h:-?} px
File:     ${size}
DPI:      ${dpi}
Format:   ${fmt:u}
Color:    ${color}"
    [[ -n "$profile" ]] && out+="
Profile:  ${profile}"
    out+="
Depth:    ${depth}"

    local cam="${make} ${model}"
    cam="${cam## }"; cam="${cam%% }"
    [[ -n "$cam" ]] && out+="
Camera:   ${cam}"
    [[ -n "$lens" ]] && out+="
Lens:     ${lens}"
    [[ -n "$created" ]] && out+="
Captured: ${created%% +*}"

    # Exposure line
    local expo=()
    [[ -n "$fnum" ]]  && expo+=("ƒ/${fnum%%.0}")
    if [[ -n "$exp" ]]; then
        if (( exp < 1 )) && (( exp > 0 )); then
            expo+=("1/$(printf '%.0f' $(( 1.0 / exp )))s")
        else
            expo+=("${exp}s")
        fi
    fi
    [[ -n "$iso" ]]   && expo+=("ISO ${iso%%.0}")
    [[ -n "$focal" ]] && expo+=("${focal%%.0}mm")
    (( ${#expo} )) && out+="
Exposure: ${(j: · :)expo}"

    print -r -- "$out"
}

# ---- main ------------------------------------------------------------------

if (( $# == 0 )); then
    osascript -e 'display dialog "No image selected." buttons {"OK"} default button "OK" with icon caution' >/dev/null 2>&1
    exit 0
fi

reports=()
for f in "$@"; do
    [[ -f "$f" ]] && reports+=("$(describe "$f")")
done

message="${(j:\n\n:)reports}"

# Escape for AppleScript string literal.
esc=${message//\\/\\\\}
esc=${esc//\"/\\\"}

osascript <<APPLESCRIPT >/dev/null 2>&1
display dialog "${esc}" buttons {"OK"} default button "OK" with title "QuickImage Info"
APPLESCRIPT
