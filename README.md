# local-db-copy

[![Tags](https://ghcr-badge.egpl.dev/frederikhs/local-db-copy/tags?trim=major)](https://github.com/frederikhs/local-db-copy/pkgs/container/local-db-copy)
[![ci](https://github.com/frederikhs/local-db-copy/actions/workflows/push.yml/badge.svg?branch=main)](https://github.com/frederikhs/local-db-copy/actions/workflows/push.yml)
[![License](https://img.shields.io/github/license/frederikhs/local-db-copy)](LICENSE)

this repository contains the parent image for a docker image is built with a postgres database inside.
This means that the final docker image will consist of a postgres database with all replicated data inside.

*Tested with databases up to ~100GB*

### Use case

As a copy of a production database for use in development. This will enable development using a copy of a production database that can be reset to the point in time of creation of said image.

### Example

See the [example](example) folder for a implementation of this image. This example has a build script that will create a `.pgass` file that is mounted inside the docker build stage so that the dump can take place with credentials that will not be commited to the image. This means that the image only containers the dumped data and not the credentials.

A pre.sql file is supplied to enable the possibility of creating databases, users and role before data is dumped.
A post.sql file is supplied to enable the possibility of modifying the dumped data before the layer is committed. This could be to anonymize the dumped data.
