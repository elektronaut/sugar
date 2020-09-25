#!/bin/bash

/opt/docker-solr/scripts/precreate-core development
cp /docker-entrypoint-initdb.d/conf/* /var/solr/data/development/conf

/opt/docker-solr/scripts/precreate-core test
cp /docker-entrypoint-initdb.d/conf/* /var/solr/data/test/conf
