#!/bin/bash
curl -F "file=@$1" localhost:7070/upload
