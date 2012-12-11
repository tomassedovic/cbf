CBF (Cloud Babel Fish)
======================

A library for converting various cloud deployment formats.

Usage
-----

    require 'cbf'

List all the supported input formats:

    CBF.parsers

List all the suported output formats:

    CBF.generators

Convert from the Aeolus Deployable XML format to Amazon CloudFormation:

    CBF.generate(:cloud_formation, CBF.parse(:aeolus, open("wordpress.xml")))



License
-------

All the files outside of the `spec/samples` directory are licensed under the Apache License Version 2.

The full text of the license can be found at: <http://www.apache.org/licenses/LICENSE-2.0>. It is also included in the attached `COPYING` file.