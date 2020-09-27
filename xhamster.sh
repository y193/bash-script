#!/bin/bash

url=`curl -s $1 | grep -o -m 1 'https://[^"/]*/[^"]*p.h264.mp4'`

if [[ "${url}" =~ ^(https://[^/]*/).*$ ]]; then
  referer=${BASH_REMATCH[1]}
else
  echo "File not found"
  exit 1
fi

echo "URL: ${url}"
echo "referer: ${referer}"

url=`curl -s -v -e $referer $url 2>&1 >/dev/null | grep -o -m 1 'location: *https://[^"/]*/[^"]*p.h264.mp4'`

if [[ "${url}" =~ ^location:[[:space:]]*(https://[^/]*/)(.*)$ ]]; then
  url=${BASH_REMATCH[1]}${BASH_REMATCH[2]}
  referer=${BASH_REMATCH[1]}
else
  echo "File not found"
  exit 1
fi

echo "URL: ${url}"
echo "referer: ${referer}"

curl -O -e $referer $url
