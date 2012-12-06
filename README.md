Instructions for setting up the example DataJoint schema

Setting up the database
-----
* Install MySQL Server
* Create a user account that has privileges to create schemas and tables.
  Note: you shouldn't use too secret a password since it's entered in plain
  text.

Configure the DataJoint library for MATLAB
----
* Clone the mym library repository

        git clone git://github.com/datajoint/mym.git
* Clone the DataJoint Git repository:

        git clone git://github.com/datajoint/datajoint-matlab.git
Configure the example schema
-----
To use the example schema:
* Clone the Git repository for the example schema:

        git clone git://github.com/datajoint/example.git
* Download the database dump file from 
        https://github.com/downloads/datajoint/example/dj_example.mat
* Start Matlab and navigate to the root directory of the example 
  repository. Edit `settings_template.m`, fill in the necessary information,
  and save it as 1settings.m`
* Run the following commands:

        startup()
        setup()
        restore('/path/to/dumpfile/dj_example.mat')

You're ready to work wit the example schema.