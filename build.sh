#!/usr/bin/env bash

docker build --no-cache \
  -t "rubensa/ubuntu-tini-dotnet" \
  --label "maintainer=Ruben Suarez <rubensa@gmail.com>" \
  .
