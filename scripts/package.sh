#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
cd "$ROOT"

VERSION=${VERSION:-$(cat VERSION)}
ARCH=${ARCH:-all}
SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH:-$(git log -1 --format=%ct 2>/dev/null || date +%s)}
export VERSION ARCH SOURCE_DATE_EPOCH

exec make package
