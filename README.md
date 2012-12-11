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

