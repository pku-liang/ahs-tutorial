#! /bin/bash

set -e

# use install.log to record the installation process
touch install.log


mkdir -p $HOME/.local/bin

echo "Downloading firtool-1.86.0..."
if ! grep -q "firtool-1.86.0" install.log; then
    wget https://github.com/llvm/circt/releases/download/firtool-1.86.0/firrtl-bin-linux-x64.tar.gz
    tar -xvf firrtl-bin-linux-x64.tar.gz
    cp -rf ./firtool-1.86.0/* $HOME/.local/
    echo "firtool-1.86.0 downloaded" >> install.log
else
    echo "|-- already exists"
fi

echo "Building cmt2..."
if ! grep -q "cmt2" install.log; then
    cd cmt2
    git submodule update --init --recursive
    cargo build --release --all
    cd ..
    echo "cmt2 built" >> install.log
else
    echo "|-- already exists"
fi

echo "Building hestia..."
if ! grep -q "hestia" install.log; then
    cd hestia && cargo build --release --all
    cd ..
    echo "hestia built" >> install.log
else
    echo "|-- already exists"
fi

LLVM_COMMIT="cbc378ecb87e3f31dd5aff91f2a621d500640412"
echo "Building mlir, at llvm-project commit $LLVM_COMMIT"
if ! grep -q "llvm-project" install.log; then
    cd llvm-project
    git checkout $LLVM_COMMIT
    git apply -p1 ../popa/mlir_link_issue.patch
    cmake -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_ENABLE_PROJECTS="clang;lld;mlir" \
        -DLLVM_TARGETS_TO_BUILD="Native" \
        -DLLVM_ENABLE_TERMINFO=OFF -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_ENABLE_LLD=OFF \
        -DLLVM_ENABLE_EH=ON -DLLVM_ENABLE_RTTI=ON -DLLVM_BUILD_32_BITS=OFF \
        -DLLVM_ENABLE_BINDINGS=OFF \
        -G Ninja -S llvm -B build
    cmake --build build
    cmake --install build --prefix install
    cd ..
    echo "llvm-project built" >> install.log
else
    echo "|-- already exists"
fi

echo "Building hector..."
if ! grep -q "hector" install.log; then
    cd hector
    git submodule update --init --recursive
    cmake -G Ninja -DMLIR_DIR=../llvm-project/build/lib/cmake/mlir -B build
    cmake --build build
    cp ./build/bin/* $HOME/.local/bin/
    cd ..
    echo "hector built" >> install.log
else
    echo "|-- already exists"
fi

echo "Building popa..."
if ! grep -q "popa" install.log; then
    export PATH=$PWD/llvm-project/install/bin:$PATH
    cd popa
    LLVM_DIR=../llvm-project/install/lib/cmake/llvm cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -B build
    cmake --build build
    cmake --install build --prefix install
    cd ..
    echo "popa built" >> install.log
else
    echo "|-- already exists"
fi

echo "Building ksim..."
if ! grep -q "ksim" install.log; then
    cd ksim
    mkdir -p install
    export INSTALL_PREFIX=$PWD/install
    git submodule update --init --recursive
    cd third_party
    ./setup-circt.sh
    ./setup-lemon.sh
    cd ..
    mkdir -p build && cd build
    cmake .. -DMLIR_DIR=../install/lib/cmake/mlir -DLLVM_DIR=../install/lib/cmake/llvm -DCIRCT_DIR=../install/lib/cmake/circt -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DCMAKE_BUILD_TYPE=Release -GNinja
    ninja ksim ksim-opt
    ninja install
    echo "cp ksim->$HOME/.local/bin/ksim, firtool->$HOME/.local/bin/firtool-ksim, llc->$HOME/.local/bin/llc-ksim"
    cd ..
    cp ./install/bin/ksim $HOME/.local/bin/ksim
    cp ./install/bin/firtool $HOME/.local/bin/firtool-ksim
    cp ./install/bin/llc $HOME/.local/bin/llc-ksim
    cd ..
    echo "ksim built" >> install.log
else
    echo "|-- already exists"
fi

echo "Building iverilog..."
if ! grep -q "iverilog" install.log; then
    cd iverilog
    sh autoconf.sh
    ./configure --prefix=$HOME/.local
    make
    make install
    cd ..
    echo "iverilog built" >> install.log
else
    echo "|-- already exists"
fi

echo "Cleaning up..."
make clean

# check ksim, firtool-ksim, llc-ksim can be found 
# Check if required tools exist in PATH
echo "Checking binary existence..."
for tool in firtool ksim firtool-ksim llc-ksim iverilog; do
    if ! command -v $tool &> /dev/null; then
        echo "Error: $tool not found in PATH"
        exit 1
    fi
done

echo "Installation completed" >> install.log
