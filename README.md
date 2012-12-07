This repoisitory contains a simple DataJoint schema to help new users learn the basics of DataJoint. 

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

* Plot the entity relationship diagram (ERD) by typing

        erd example

You should see the following diagram, which depicts the objects in the schema and their dependencies, directed top-to-bottom.
<p align=center>
<img src=https://raw.github.com/datajoint/example/master/example.png>
</p> 
You can proceed to [Lesson 1](https://github.com/datajoint/example/wiki/)