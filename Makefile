ci: clean deps lint package

clean:
	rm -rf bin/ pkg/ stage/ vendor/

deps:
	gem install bundler --version=1.17.3
	bundle config --local path vendor/bundle
	bundle install --binstubs

lint:
	bundle exec puppet-lint \
		--fail-on-warnings \
		--no-140chars-check \
		--no-autoloader_layout-check \
		--no-documentation-check \
		manifests/*.pp
	bundle exec rubocop --config .rubocop.yml Gemfile
	PDK_DISABLE_ANALYTICS=true pdk validate metadata

package:
	PDK_DISABLE_ANALYTICS=true pdk build --force

release:
	rtk release

.PHONY: ci clean deps lint package release
