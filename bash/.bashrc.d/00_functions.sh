
view() {
    # if there are no arguments
    if [[ $# -eq 0 ]]; then
        PATTERN="${PWD}/README*"
        # if a file matching PATTERN exists
        # see https://stackoverflow.com/a/6364244
        if compgen -G "${PATTERN}" > /dev/null; then
            # go through the list of matching files
            for f in ${PATTERN}; do
                # we remember the first matching one and leave
                FILE=$f
                break
            done
        fi
    else
        # if there are arguments, then we just get the name of the file
        FILE="$*"
    fi
    
    # if we found a FILE
    if [[ -n ${FILE} ]]; then
        # create a temp file
        TMP_HTML=$(mktemp XXXXX.html)
        # convert the file to html4 and write to TMP_HTML
        pandoc --to html4 -o - "${FILE}" > ${TMP_HTML}
        # then open with w3m
        w3m ${TMP_HTML}
        # and eventually clean up
        rm ${TMP_HTML}
    fi

}

: '
some ideas for the view function:

pdf -> ocr and pipe output

format casting, probably unneccessary

BASE=$(basename ${FILE})
# NAME holds everything before, and  EXT after the first dot
NAME=${BASE%.}
EXT=${BASE##*.}

# if there is no extension we can assume markdown, like pandoc would
# if there is, we assume markdown for txt as well
if [[ -n ${EXT} ]]; then
    case ${EXT} in
        txt)
        FORMAT=markdown
        ;;
    esac
'

gh_info() {
    # takes two args: github user/organization and reponame
    curl -sL https://api.github.com/repos/"${1}"/"${2}"/releases/latest
}

gh_version() {
    # takes two args: github user/organization and reponame
    # returns the tag of the latest release
    gh_info "${1}" "${2}" | jq -r ".tag_name"
}

gh_release() {
    # takes three args: github user/organization, reponame and a searchterm for the wanted artifact (e.g. software_linux_amd64.tar.gz)
    # returns the download link for the artifact
    gh_info "${1}" "${2}" | jq -r ".assets[].browser_download_url" | grep "${3}"
}

gh_tarball() {
    # takes two args: github user/organization and reponame
    # returns the download link for the tarball
    gh_info "${1}" "${2}" | jq -r ".tarball_url"
}

find_dir_in_tarball() {
    # find the FIRST directory (or file) in a tarball
    tar tzf "${1}" | head -1 | cut -f1 -d/
}

wrap_text() {
    # Default values for width and indent
    local width=80
    local indent=10

    # Check if width and indent are provided as arguments
    if [ -n "$1" ]; then
        width="$1"
    fi
    if [ -n "$2" ]; then
        indent="$2"
    fi

    local pad
    pad=$(printf '%*s' "$indent")

    while IFS= read -r line; do
        while [ ${#line} -gt "$width" ]; do
            # Find the last space within the width limit
            local i
            i=$width
            while [ $i -gt 0 ] && [ "${line:i-1:1}" != " " ]; do
                ((i--))
            done
            if [ $i -eq 0 ]; then
                # No space found, break at width
                i=$width
            fi
            # Print the wrapped line
            echo "${line:0:i}"
            # Update the line to continue from the next character
            line="${pad}${line:i}"
        done
        # Print the last, potentially unwrapped line
        echo "$line"
    done
}

