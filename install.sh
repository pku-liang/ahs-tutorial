#! /bin/bash

echo "Building cmt2..."
cd cmt2 && cargo build --release --all && cd ..
echo "Building hestia..."
cd hestia && cargo build --release --all && cd ..

# check ksim, firtool-ksim, llc-ksim can be found 
# Check if required tools exist in PATH
echo "Checking ksim existence..."
for tool in ksim firtool-ksim llc-ksim; do
    if ! command -v $tool &> /dev/null; then
        echo "Error: $tool not found in PATH"
        exit 1
    fi
done

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
cd Hector
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
