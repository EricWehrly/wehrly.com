`docker build -t wehrly.com .`

`docker run -dit -v "$(pwd -W)":/usr/local/apache2/htdocs/ -p 8080:80 wehrly.com`