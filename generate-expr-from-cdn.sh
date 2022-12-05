#!/usr/bin/env bash

process_dep() {
    local pack="$1"
    remotepath=$(echo "$pack" | perl -n -e '/RemotePath="([^"]*)"/ && print $1')
    hash=$(echo "$pack" | perl -n -e '/Hash="([^"]*)"/ && print $1')
    url="http://cdn.unrealengine.com/dependencies/$remotepath/$hash"

    until sha256=$(nix-prefetch-url $url --type sha256); do
        true
    done

    cat <<EOF
  "$hash" = fetchurl {
    url = $url;
    sha256 = "$sha256";
  };
EOF
}
export -f process_dep

go() {
    file="$1"

    IFS=$'\n'
    perl -n -e '/(<Pack .*\/>)/ && print "$1\n"' $file | parallel -j20 --keep-order --verbose process_dep "{}"
}


cat <<EOF
{ fetchurl }:

{
EOF

go Engine/Build/Commit.gitdeps.xml
go Engine/Build/Promoted.gitdeps.xml

cat <<EOF
}
EOF
