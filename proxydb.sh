#!/bin/bash

# Run me with ./proxydb.sh and then access production database through port 15432

flyctl proxy 15432:5432 -a the-little-thinkers-space-db