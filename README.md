# calmeq-mypi
[![Circle CI](https://circleci.com/gh/CalmEQ/calmeq-mypi.svg?style=shield)](https://circleci.com/gh/CalmEQ/calmeq-mypi)
[![Dependency Status](https://gemnasium.com/CalmEQ/calmeq-mypi.svg)](https://gemnasium.com/CalmEQ/calmeq-mypi)

Git directory of scripts and configuration to initialize, configure and run a raspberry pi


## Organization

This repo is basically three projects in one:

1. Setup and initial configuration for a raspberry pi into a calmeq mypi
2. Record, process, and push noise lvls to the calmeq-devices server
3. Webserver to view and configure the raspberry pi by connecting directly to the device

Currently the code is organized into folders for each task, with the most important setup scripts 
at the root level. A partial listing

* `apache2` - setup for the local webserver
* `bin` - shell scripts
* `circle.yml` - configuration for circleci.com testing server
* `env.sh - global` environment variables
* `mypi-init.sh` - core setup script for all 3 projects
* `notes.txt` - random notes
* `pi.crontab` - the crontab that keeps everything running
* `preinstall` - directory of configuration for initial pi setup
* `python` - python scripts used in record, process and pushing 
* `requirements.txt` - requirements for python
* `test` - test scripts
* `tunnel.rsa.pub` - used to form the connection to amazon aws
* `webhook` - sets up the ci testing from github automatic pulls
* `www` - php and html files for local webserver for configuration



## Testing

Current testing paradigm is two-fold:

1. Circle-ci testing for the python scripts, and anything else we can isolate from the pi
2. A dedicated raspberry pi setup to pull latest code and test the setup, recording, and push. Full integegration testing





Project Copyright 2015 CalmEQ

