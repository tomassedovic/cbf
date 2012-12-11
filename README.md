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



How it works
------------

When CBF reads an input format, it converts its contents into an internal representation that contains all the information and is the same for all the formats.

The generator for the output format receives this internal structure and converts it to the desired output.

If you want to add supports for new formats, you will need work with this internal resource format.

The specification is here:

<https://github.com/tomassedovic/cbf/wiki/Internal-resource-format>


Short-term Roadmap
------------------

* Fully document the internal resource format
* Add more extensive tests
* Publish to Rubygems


License
-------

All the files outside of the `spec/samples` directory are licensed under the Apache License Version 2.

The full text of the license can be found at: <http://www.apache.org/licenses/LICENSE-2.0>. It is also included in the attached `COPYING` file.