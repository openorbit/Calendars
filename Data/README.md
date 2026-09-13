# Astronomy source data

This directory contains upstream inputs used to generate the compact astronomy
tables shipped by the Calendars package. These files are generator inputs, not
package resources.

Recreate the directory from the upstream CDS and JPL distributions with:

```sh
Packages/Calendars/Scripts/bootstrap-astronomy-data.sh
```

The DE441 little-endian ephemeris is several gigabytes. Downloads are resumable,
existing files are skipped, and it can be omitted when only rebuilding the star
catalogue inputs:

```sh
Packages/Calendars/Scripts/bootstrap-astronomy-data.sh --skip-de441
```

The expected inputs are:

- `YBSC5`: Bright Star Catalogue, Fifth Revised Edition, CDS V/50.
- `Hipparcos-I-239`: original Hipparcos main catalogue, used as an identifier bridge.
- `Hipparcos-2-CDS`: van Leeuwen Hipparcos new reduction, CDS I/311.
- `DE441`: JPL DE441 little-endian ephemeris, header, and test positions.

Use `--force` to refresh files that are already present. Review upstream catalogue
revisions and generator regression results before committing newly generated
tables.
