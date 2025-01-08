#! /bin/bash

echo "Downloading firtool-1.86.0..."
wget https://github.com/llvm/circt/releases/download/firtool-1.86.0/firrtl-bin-linux-x64.tar.gz
tar -xvf firrtl-bin-linux-x64.tar.gz
cp -rf ./firtool-1.86.0/* $HOME/.local/

echo "Building cmt2..."
cd cmt2 && cargo build --release --all && cd ..

echo "Building hestia..."
cd hestia && cargo build --release --all && cd ..

LLVM_COMMIT="cbc378ecb87e3f31dd5aff91f2a621d500640412"
echo "Building mlir, at llvm-project commit $LLVM_COMMIT"
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

echo "Building hector..."
cd hector
git submodule update --init --recursive
cmake -G Ninja -DMLIR_DIR=../llvm-project/build/lib/cmake/mlir -B build
cmake --build build
cd ..

echo "Building popa..."
export PATH=$PWD/llvm-project/install/bin:$PATH
cd popa
LLVM_DIR=../llvm-project/build/lib/cmake/llvm cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -B build
cmake --build build
cd ..

echo "Building ksim..."
cd ksim
mkdir -p install
export INSTALL_PREFIX=$PWD/install
git submodule update --init --recursive
cd third_party
./setup-circt.sh
./setup-lemon.sh
cd ..
mkdir -p build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DCMAKE_BUILD_TYPE=Release -GNinja
ninja ksim ksim-opt
ninja install
echo "cp ksim->$HOME/.local/bin/ksim, firtool->$HOME/.local/bin/firtool-ksim, llc->$HOME/.local/bin/llc-ksim"
cd ..
cp ./install/bin/ksim $HOME/.local/bin/ksim
cp ./install/bin/firtool $HOME/.local/bin/firtool-ksim
cp ./install/bin/llc $HOME/.local/bin/llc-ksim
cd ..


# check ksim, firtool-ksim, llc-ksim can be found 
# Check if required tools exist in PATH
echo "Checking binary existence..."
for tool in firtool ksim firtool-ksim llc-ksim; do
    if ! command -v $tool &> /dev/null; then
        echo "Error: $tool not found in PATH"
        exit 1
    fi
done