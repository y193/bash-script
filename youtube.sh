#!/bin/bash

mkdir -p ./youtube
cd ./youtube

if [[ $1 =~ ^https://www.youtube.com/watch\?v=([^&]+).* ]]; then
  video_id=${BASH_REMATCH[1]}
  url="https://www.youtube.com/get_video_info?video_id=${video_id}"
else
  echo "File not found"
  exit 1
fi

echo "URL: ${url}"
curl -s -A 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.2 Safari/605.1.15' \
  -o ./get_video_info $url

url=`sed -e 's/https/\'$'\nhttps/g' ./get_video_info \
  | sed -e 's/%3A/:/g' \
  | sed -e 's/%2F/\//g' \
  | sed -e 's/%25/%/g' \
  | sed -e 's/%2C/,/g' \
  | grep -o -m 1 'https.*index\.m3u8'`

if [[ -z "${url}" ]]; then
  echo "File not found"
  exit 1
fi

echo "URL: ${url}"
curl -s -o ./index.m3u8 $url

i=1

for url in `grep -o 'https.*index\.m3u8' ./index.m3u8`; do
  mkdir -p "./${i}"

  m3u8="./${i}/index.m3u8"
  mp4="./${i}/${video_id}.mp4"

  curl -s -o $m3u8 $url

  if [[ -n `grep -o -m 1 'https.*\.ts' $m3u8` ]]; then
    ffmpeg -nostdin -protocol_whitelist crypto,file,http,https,tcp,tls \
      -i $m3u8 -movflags faststart -c copy $mp4
  fi

  i=`expr $i + 1`
done
