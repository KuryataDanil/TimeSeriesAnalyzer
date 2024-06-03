#!/bin/bash

# Убедитесь, что версия передана в качестве аргумента
if [ -z "$1" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

VERSION=$1
GEM_NAME="TimeSeriesAnalyzer"
GEM_FILE="${GEM_NAME}-${VERSION}.gem"

# Обновите версию в gemspec
sed -i "s/spec.version\s*=.*/spec.version       = '$VERSION'/" ${GEM_NAME}.gemspec

# Постройте gem
gem build ${GEM_NAME}.gemspec

echo "Gem file created: ${GEM_FILE}"
