Instructions to setting up the example DataJoint schema

General prerequisites
* Install MySQL Server
* Create a user account that has privileges to create schemas and tables.
  Note: you shouldn't use too secret a password since it's entered in plain
  text.
* Clone the DataJoint Git repository:
        git://github.com/datajoint/datajoint-matlab.git

To use the example schema:
* Clone the Git repository for the example schema:
        git://github.com/datajoint/example.git
* Download the database dump file:
        https://github.com/downloads/datajoint/example/dj_example.mat
* Start Matlab and navigate to the root directory of the example 
  repository. Edit settings_template.m, fill in the necessary information,
  and save it as settings.m
* Run the following commands:
    startup()
    setup()
    restore('/path/to/dumpfile/dj_example.mat')

You're done.

