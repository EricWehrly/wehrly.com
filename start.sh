#!/bin/bash

docker build -t wehrly.com .

docker run -dit -v "$(pwd -W)":/usr/local/apache2/htdocs/ -p 8081:80 wehrly.com