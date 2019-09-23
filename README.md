Welcome to the rUNSWift 2019 git repository.

The directory structure is:

* **bin**:
    This is where any executables are stored, such as configuration scripts (build_setup, nao_sync)
* **image**:
    The contents of this directory are synced to the robot with nao_sync, put custom configuration files
    or libraries here. Python code that handles behaviour decision making exists here.
* **robot**:
    This is the source code for the rUNSWift binaries, including our core architecture.
* **utils**:
    This is the source code for any off-nao utilities, such as colour
    calibration or offline debugging utilities.

The [manual](https://unswcomputing.github.io/rUNSWift-Manual/index.html) holds the documentation.

Of note:

* [Running the Robot](https://unswcomputing.github.io/rUNSWift-Manual/running/index.html)
* [Architecture](https://unswcomputing.github.io/rUNSWift-Manual/architecture.html)
