# AHS Tutorial

This repository holds the code of frameworks involved in the tutorial ["AHS: An EDA toolbox for Agile Chip Front-end Design"](https://ericlyun.me/tutorial-aspdac2025/en/master/#ahs-an-eda-toolbox-for-agile-chip-front-end-design).

## Installation

### Docker

We recommend using Docker to try out the frameworks.

#### Using Built Docker Image

We provide a built Docker image for the tutorial. You can pull it from Docker Hub:

```bash
docker pull uvxiao/ahs-tutorial:aspdac2025
```

#### Building Docker Image from Source

You can refer to [ahs-docker](https://github.com/pku-liang/ahs-docker) for instructions.

### Local Installation

We also provide a local installation script for the tutorial. Some prerequisites are required, please refer to [Dockerfile](https://github.com/pku-liang/ahs-docker/blob/main/Dockerfile) as a reference.

Then, you can run the following commands to install the frameworks:

```bash
git clone git@github.com:arch-of-shadow/ahs-tutorial.git
cd ahs-tutorial
git submodule update --init
bash install.sh
```

## First Taste

After installation, you can run the following commands to have the first taste of the frameworks (also validate the installation):

> [!NOTE]
> Fill this section.

### Cement

Introductions on the **cmtrs** embedded language, the **cmtc** compiler, and some examples will be presented at the tutorial.

Please read the [documentation](https://docs.rs/cmtrs/latest/cmtrs/) for the basic concepts and language usage.

#### Contents

The examples are in `cmt2\crates\cmtc\examples` directory.

We will demonstrate these examples
```
fir.rs: Finite Impulse Response filter. 
|- fn fir3_3(): shows how to write an FIR with fixed length 3. 
|- fn gen_fir(): shows how to generate FIR with arbitrary length.
|- fn gen_fir_addertree(): further implements the FIR with an adder tree, which demonstrates the use of #[gen_fn] to generate hardware recursively.
|- fn make_tb(): demonstrates how to write a testbench in cmtrs.

gemm.rs: General Matrix Multiplication
|- fn mac(): A multiply-accumulate unit to be used in the GeMM example.
|- fn gemm(): A GeMM unit with only one MAC, which is controlled by a three-level for loop FSM. 
|- fn tb(): A testbench for gemm.

gemm_unrolled.rs: Unrolled gemm
|- fn mac(): A multiply-accumulate unit to be used in the GeMM example.
|- fn gemm_unrolled(): A GeMM unit with ``#factor`` MACs, the innermost loop is unrolled and the memories are partitioned.
|- fn tb(): A testbench for gemm_unrolled.
```
#### Running Examples

Steps to run an example

```shell
cd cmt2
cargo run --example <name_of_example>
```

Results:

- A generated System Verilog file at the root directory
- A Khronos simulation environment in `tb` directory

#### Simulation with Khronos

After running an example

```shell
cd tb/<name_of_example>
make all
./<executable_name>
```

Results:

- The executable will simulate the generated hardware, and prints the `sim_print!` messages in the testbench.

