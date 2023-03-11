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

The documentation can be found [here](https://runswift.readthedocs.io/en/2019/index.html).

Of note:

* [Running the Robot](https://runswift.readthedocs.io/en/2019/running/index.html)
* [Architecture](https://runswift.readthedocs.io/en/2019/architecture.html)

## v5 support
To any teams (or curious historians, software archaeologists or enthusiasts) with [Nao Evolution (V5) (2014) robots](https://en.wikipedia.org/wiki/Nao_(robot)#Specifications). This was the last rUNSWift code release to officially support and work on the v5 series of Nao robots (though 2019 was played in Sydney primarily or even exclusively with v6 robots, so [2018](https://github.com/UNSWComputing/rUNSWift-2018-release/) could be a better release). [2022](https://github.com/UNSWComputing/rUNSWift-2022-release/) is known to no longer support v5 (and indeed has been tested to have compilation errors), though legacy v5 code may not necessarily have been removed.

Test results (on Ubuntu 18.04.6 LTS on a 2011 Macbook Air, see the [2019 docs here](https://runswift.readthedocs.io/en/2019/setup/index.html))
1. ✅ With a 2.1.4.13 FR (factory reset) USB, flash to the Softbank state
2. ✅ Use http://nao.local/ to change the robot's name to robot1
3. ✅ Build and sync runswift
4. ✅ SSH in and start runswift
5. ✅ Start offnao
6. ✅ Connect via offnao to see regions of interest (though not a ball which should if detected have been shown with a bold black circle around it, and cause one of the eyes to flash red)
7. (unable to test) The v5 I was using was unable to be stiffened with a double tap to its chest

![IMG_8954](https://user-images.githubusercontent.com/1217010/224469685-8a5f9939-513f-45db-9e4d-27e3c38afb96.jpg)
