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

Generate the compact naked-eye star catalogue from these inputs with:

```sh
cd Packages/Calendars
swift run AstronomyDataTool
```

The tool joins YBSC HR/HD identities to Hipparcos identifiers using I/239, then
uses the improved I/311 astrometry. Ambiguous and unmatched records are reported
and omitted. Its default output is
`Sources/Calendars/Resources/AstronomyData/historical-stars.bin`.

Before generating event tables, validate the random-access DE441 reader against
JPL's distributed test positions:

```sh
swift run AstronomyDataTool validate-de441
```

The command samples positions and velocities across the ephemeris range and
fails if their absolute error exceeds `1e-11` AU (or AU/day). The large DE441
binary remains an ignored generator input; only derived compact tables belong in
the package resources.

Validate the long-term Vondrák–Capitaine–Wallace equator and ecliptic model with:

```sh
swift run AstronomyDataTool validate-reference-frame
```

This model is used instead of extrapolating the modern IAU 2006 polynomial over
the full historical range. The implementation is adapted from the IAU SOFA
long-term routines; its provenance and license requirements are recorded beside
the generator source in `SOFA-NOTICE.md`.
