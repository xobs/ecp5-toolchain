#!/bin/sh -x
set -e

win_nextpnr_url="https://github.com/xobs/toolchain-nextpnr-ecp5/releases/download/v1.5.3/nextpnr-ecp5-windows_amd64-v1.5.3.zip"
win_yosys_url="https://github.com/xobs/toolchain-icestorm/releases/download/v1.38-fomu/toolchain-icestorm-windows_amd64-v1.38-fomu.zip"
win_wishbone_tool_url="https://github.com/xobs/wishbone-utils/releases/download/v0.4.7/wishbone-tool-v0.4.7-x86_64-pc-windows-gnu.tar.gz"
win_riscv_url="https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-w64-mingw32.zip"
win_python_url="https://www.python.org/ftp/python/3.7.3/python-3.7.3-embed-amd64.zip"
win_make_url="https://sourceforge.net/projects/ezwinports/files/make-4.2.1-without-guile-w32-bin.zip/download"
win_git_url="https://anaconda.org/anaconda/git/2.23.0/download/win-64/git-2.23.0-h6bb4b03_0.tar.bz2"
win_teraterm_url="https://osdn.net/frs/redir.php?m=constant&f=ttssh2%2F71232%2Fteraterm-4.103.zip"

mac_nextpnr_url="https://github.com/xobs/toolchain-nextpnr-ecp5/releases/download/v1.5.3/nextpnr-ecp5-darwin-v1.5.3.tar.gz"
mac_yosys_url="https://github.com/xobs/toolchain-icestorm/releases/download/v1.38-fomu/toolchain-icestorm-darwin-v1.38-fomu.tar.gz"
mac_wishbone_tool_url="https://github.com/xobs/wishbone-utils/releases/download/v0.4.7/wishbone-tool-v0.4.7-x86_64-apple-darwin.tar.gz"
mac_riscv_url="https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-apple-darwin.tar.gz"
mac_make_url="https://anaconda.org/conda-forge/make/4.2/download/osx-64/make-4.2-h01d97ff_0.tar.bz2"
mac_git_url="https://anaconda.org/anaconda/git/2.23.0/download/osx-64/git-2.23.0-pl526h6951d83_0.tar.bz2"

linux_nextpnr_url="https://github.com/xobs/toolchain-nextpnr-ecp5/releases/download/v1.5.3/nextpnr-ecp5-linux_x86_64-v1.5.3.tar.gz"
linux_yosys_url="https://github.com/xobs/toolchain-icestorm/releases/download/v1.38-fomu/toolchain-icestorm-linux_x86_64-v1.38-fomu.tar.gz"
linux_wishbone_tool_url="https://github.com/xobs/wishbone-utils/releases/download/v0.4.7/wishbone-tool-v0.4.7-x86_64-unknown-linux-gnu.tar.gz"
linux_riscv_url="https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-centos6.tar.gz"
linux_make_url="https://anaconda.org/conda-forge/make/4.2/download/linux-64/make-4.2-h516909a_0.tar.bz2"
linux_git_url="https://anaconda.org/anaconda/git/2.23.0/download/linux-64/git-2.23.0-pl526hacde149_0.tar.bz2"

base="$(pwd)"
output_name="ecp5-toolchain-${ARCH}-${TRAVIS_TAG}"
output="${base}/output/${output_name}"
input="${base}/input"

mkdir -p $output
mkdir -p $input
mkdir -p $output/bin

if [ -z ${TRAVIS_TAG} ]
then
    echo "This repository is designed to be run in the Travis CI system."
    echo "Please download the prebuilt distribution for your platform at:"
    echo "https://github.com/im-tomu/fomu-toolchain/releases/latest"
    exit 1
fi

checksum_output() {
    set +x
    hashes="sha1 sha256 sha512"
    local outfile hashfile
    outfile=$output$1

    for hash in $hashes ; do
	hashfile=$outfile.$hash
        ${hash}sum $outfile > $hashfile
	echo -n "$hash: " ; cat $hashfile
    done
    set -x
}

case "${ARCH}" in
    "windows")
        # Python 3.7.3 (which matches the version in nextpnr)
        wget -O $input/python-${ARCH}.zip "$win_python_url"
        cd $output/bin
        unzip -o $input/python-${ARCH}.zip
        rm python37.zip # we already have this unzipped from nextpnr-ecp5
        rm -f python37._pth # If this file is present, PYTHONPATH is very broken

        # Nextpnr
        wget -O $input/nextpnr-${ARCH}.zip "$win_nextpnr_url"
        cd $output
        unzip -o $input/nextpnr-${ARCH}.zip

        # Yosys, icestorm, and dfu_util
        wget -O $input/icestorm-${ARCH}.zip "$win_yosys_url"
        cd $output
        unzip -o $input/icestorm-${ARCH}.zip

        # Teraterm Terminal
        wget -O $input/teraterm-${ARCH}.zip "$win_teraterm_url"
        cd $output/bin
        unzip -o $input/teraterm-${ARCH}.zip
        mv teraterm-*/* .
        rmdir teraterm-* || true

        # Wishbone Tool
        wget -O $input/wishbone-tool-${ARCH}.tar.gz "$win_wishbone_tool_url"
        cd $output/bin
        tar xvzf $input/wishbone-tool-${ARCH}.tar.gz

        # Riscv Toolchain
        # Note that we want to strip the front part of the path.
        # Also, we do "cp -l" then "rm -rf" to merge the directories.
        wget -O $input/riscv-${ARCH}.zip  "$win_riscv_url"
        cd $input
        mkdir re
        cd re
        unzip -o $input/riscv-${ARCH}.zip
        cp -f -l -r */* $output
        cd ..
        rm -rf re

        # Make.exe
        wget -O $input/make-${ARCH}.zip "$win_make_url"
        cd $output
        unzip -o $input/make-${ARCH}.zip

        # Git
        wget -O $input/git-${ARCH}.tar.bz2 "$win_git_url"
        cd $output
        tar xvjf $input/git-${ARCH}.tar.bz2
        rm -rf input

        # Extra files on Windows (sh.exe, cp.exe, etc.)
        cp -a $base/* $output/bin

        # This causes issues on Windows, which is case-insensitive
        rm -f $output/bin/license.txt $output/bin/LICENSE.txt

        cd $base/output
        zip -r $output_name.zip $output_name
        checksum_output .zip
        ;;

    "macos")
        # Nextpnr
        wget -O $input/nextpnr-${ARCH}.tar.gz "$mac_nextpnr_url"
        cd $output
        tar xvzf $input/nextpnr-${ARCH}.tar.gz

        # Yosys, icestorm, and dfu_util
        wget -O $input/icestorm-${ARCH}.tar.gz "$mac_yosys_url"
        cd $output
        tar xvzf $input/icestorm-${ARCH}.tar.gz

        # Wishbone Tool
        wget -O $input/wishbone-tool-${ARCH}.tar.gz "$mac_wishbone_tool_url"
        cd $output/bin
        tar xvzf $input/wishbone-tool-${ARCH}.tar.gz

        # Riscv Toolchain
        # Note that we want to strip the front part of the path.
        # Also, we do "cp -l" then "rm -rf" to merge the directories.
        wget -O $input/riscv-${ARCH}.tar.gz  "$mac_riscv_url"
        cd $input
        mkdir re
        cd re
        tar xvzf $input/riscv-${ARCH}.tar.gz
        cp -f -l -r */* $output
        cd ..
        rm -rf re

        # Git
        wget -O $input/git-${ARCH}.tar.bz2 "$mac_git_url"
        cd $output
        tar xvjf $input/git-${ARCH}.tar.bz2
        rm -rf input

        # Make
        wget -O $input/make-${ARCH}.tar.bz2 "$mac_make_url"
        cd $output
        tar xvjf $input/make-${ARCH}.tar.bz2
        rm -rf input

        cd $base/output
        zip -r $output_name.zip $output_name
        checksum_output .zip
        ;;

    "linux_x86_64")
        # Nextpnr
        wget -O $input/nextpnr-${ARCH}.tar.gz "$linux_nextpnr_url"
        cd $output
        tar xvzf $input/nextpnr-${ARCH}.tar.gz

        # Yosys, icestorm, and dfu_util
        wget -O $input/yosys-${ARCH}.tar.gz "$linux_yosys_url"
        cd $output
        tar xvzf $input/yosys-${ARCH}.tar.gz

        # Wishbone Tool
        wget -O $input/wishbone-tool-${ARCH}.tar.gz "$linux_wishbone_tool_url"
        cd $output/bin
        tar xvzf $input/wishbone-tool-${ARCH}.tar.gz

        # Riscv Toolchain
        # Note that we want to strip the front part of the path.
        # Also, we do "cp -l" then "rm -rf" to merge the directories.
        wget -O $input/riscv-${ARCH}.tar.gz "$linux_riscv_url"
        cd $input
        mkdir re
        cd re
        tar xvzf $input/riscv-${ARCH}.tar.gz
        cp -f -l -r */* $output
        cd ..
        rm -rf re

        # Git
        wget -O $input/git-${ARCH}.tar.bz2 "$linux_git_url"
        cd $output
        tar xvjf $input/git-${ARCH}.tar.bz2
        rm -rf input

        # Make
        wget -O $input/make-${ARCH}.tar.bz2 "$linux_make_url"
        cd $output
        tar xvjf $input/make-${ARCH}.tar.bz2
        rm -rf input

        cd $base/output
        tar cvzf $output_name.tar.gz $output_name
        checksum_output .tar.gz
        ;;
    *)
        echo "Unrecognized architecture: ${ARCH}"
        echo "Supported architectures: macos, windows, linux_x86_64"
        exit 1
        ;;
esac

echo "${TRAVIS_TAG}" > $output/VERSION

exit 0
