# SPDX-FileCopyrightText: Bernhard Posselt <dev@bernhard-posselt.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# Generic Makefile for building and packaging a Nextcloud app which uses npm and
# Composer.
#
# Dependencies:
# * make
# * which
# * curl: used if phpunit and composer are not installed to fetch them from the web
# * tar: for building the archive
# * npm: for building and testing everything JS
#
# If no composer.json is in the app root directory, the Composer step
# will be skipped. The same goes for the package.json which can be located in
# the app root or the js/ directory.
#
# The npm command by launches the npm build script:
#
#    npm run build
#
# The npm test command launches the npm test script:
#
#    npm run test
#
# The idea behind this is to be completely testing and build tool agnostic. All
# build tools and additional package managers should be installed locally in
# your project, since this won't pollute people's global namespace.
#
# The following npm scripts in your package.json install and update the bower
# and npm dependencies and use gulp as build system (notice how everything is
# run from the node_modules folder):
#
#    "scripts": {
#        "test": "node node_modules/gulp-cli/bin/gulp.js karma",
#        "prebuild": "npm install && node_modules/bower/bin/bower install && node_modules/bower/bin/bower update",
#        "build": "node node_modules/gulp-cli/bin/gulp.js"
#    },

app_name=simplevideos
build_tools_directory=$(CURDIR)/build/tools
source_build_directory=$(CURDIR)/build/artifacts/source
source_package_name=$(source_build_directory)/$(app_name)
appstore_build_directory=$(CURDIR)/build/artifacts/appstore
appstore_package_name=$(appstore_build_directory)/$(app_name)
tmp_source_directory=$(CURDIR)/.tmp/sources/$(app_name)
tmp_appstore_directory=$(CURDIR)/.tmp/appstore/$(app_name)
npm=$(shell which npm 2> /dev/null)
composer=$(shell which composer 2> /dev/null)

all: build

# Fetches the PHP and JS dependencies and compiles the JS. If no composer.json
# is present, the composer step is skipped, if no package.json or js/package.json
# is present, the npm step is skipped
.PHONY: build
build:
ifneq (,$(wildcard $(CURDIR)/composer.json))
	make composer
endif
ifneq (,$(wildcard $(CURDIR)/package.json))
	make npm
endif
ifneq (,$(wildcard $(CURDIR)/js/package.json))
	make npm
endif

# Installs and updates the composer dependencies. If composer is not installed
# a copy is fetched from the web
.PHONY: composer
composer:
ifeq (, $(composer))
	@echo "No composer command available, downloading a copy from the web"
	mkdir -p $(build_tools_directory)
	curl -sS https://getcomposer.org/installer | php
	mv composer.phar $(build_tools_directory)
	php $(build_tools_directory)/composer.phar update
	php $(build_tools_directory)/composer.phar install --prefer-dist
else
	composer update
	composer install --prefer-dist
endif

# Installs npm dependencies
.PHONY: npm
npm:
ifeq (,$(wildcard $(CURDIR)/package.json))
	$(npm) install
	cd js && $(npm) run build
else
	npm install
	npm run build
endif

# Removes the appstore build
.PHONY: clean
clean:
	rm -rf ./build

# Same as clean but also removes dependencies installed by composer, bower and
# npm
.PHONY: distclean
distclean: clean
	rm -f composer.lock
	rm -rf vendor
	rm -rf node_modules
	rm -rf js
	

# Builds the source and appstore package
.PHONY: dist
dist:
	make source
	make appstore

# Builds the source package
.PHONY: source
source:
	rm -rf $(source_build_directory)
	rm -rf $(tmp_source_directory)

	mkdir -p $(source_build_directory)
	mkdir -p $(tmp_source_directory)

	cp -R "$(CURDIR)/LICENSES" $(tmp_source_directory)/
	cp -R "$(CURDIR)/appinfo" $(tmp_source_directory)/
	cp -R "$(CURDIR)/lib" $(tmp_source_directory)/
	cp -R "$(CURDIR)/src" $(tmp_source_directory)/
	cp -R "$(CURDIR)/Makefile" $(tmp_source_directory)/
	cp -R "$(CURDIR)/README.md" $(tmp_source_directory)/
	cp -R "$(CURDIR)/composer.json" $(tmp_source_directory)/
	cp -R "$(CURDIR)/package.json" $(tmp_source_directory)/
	cp -R "webpack.config.js" $(tmp_source_directory)/

	cd $(tmp_source_directory)/.. ; tar --exclude '.DS_Store' -czvf $(source_package_name).tar.gz $(app_name)
	
	rm -rf $(tmp_source_directory)

# Builds the source package for the app store, ignores php and js tests
.PHONY: appstore
appstore:
	rm -rf $(appstore_build_directory)
	rm -rf $(tmp_appstore_directory)

	mkdir -p $(appstore_build_directory)
	mkdir -p $(tmp_appstore_directory)
	
	# cp "$(CURDIR)/AUTHORS.md" $(tmp_appstore_directory)/
	# cp "$(CURDIR)/CHANGELOG.md" $(tmp_appstore_directory)/
	# cp "$(CURDIR)/COPYING" $(tmp_appstore_directory)/
	cp -R "$(CURDIR)/LICENSES" $(tmp_appstore_directory)/
	cp "$(CURDIR)/README.md" $(tmp_appstore_directory)/
	cp -R "$(CURDIR)/appinfo" $(tmp_appstore_directory)/
	# cp -R "$(CURDIR)/css" $(tmp_appstore_directory)/
	# cp -R "$(CURDIR)/docs" $(tmp_appstore_directory)/
	# cp -R "$(CURDIR)/img" $(tmp_appstore_directory)/
	cp -R "$(CURDIR)/js" $(tmp_appstore_directory)/
	# cp -R "$(CURDIR)/l10n" $(tmp_appstore_directory)/
	cp -R "$(CURDIR)/lib" $(tmp_appstore_directory)/
	# cp -R "$(CURDIR)/screenshots" $(tmp_appstore_directory)/
	# cp -R "$(CURDIR)/templates" $(tmp_appstore_directory)/
	cp -R "$(CURDIR)/vendor" $(tmp_appstore_directory)/

	cd $(tmp_appstore_directory)/.. ; tar --exclude '.DS_Store' -czvf $(appstore_package_name).tar.gz $(app_name)

	rm -rf $(tmp_appstore_directory)
