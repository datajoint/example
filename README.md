Instructions
====

Set up the database server
-----
* Install MySQL Server
* Create a user account that has privileges to create schemas and tables.

  Note: do not use your secret password since it will be entered in plain text.

Configure the DataJoint library for MATLAB
----
* Clone the mym library repository

        git clone git://github.com/datajoint/mym.git
* Clone the DataJoint Git repository:

        git clone git://github.com/datajoint/datajoint-matlab.git

Configure the example schema
-----
* Clone the Git repository for the example schema:

        git clone git://github.com/datajoint/example.git
* Download the database dump file from 
        https://github.com/downloads/datajoint/example/dj_example.mat
* Start Matlab and navigate to the root directory of the example 
  repository. Edit `settings_template.m`, fill in the necessary information,
  and save it as `settings.m`
* Run the following commands:

        startup()
        setup()
        restore('/path/to/dumpfile/dj_example.mat')

You're ready to work with the example schema.