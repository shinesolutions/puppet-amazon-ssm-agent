ci: clean deps lint package

deps:
	gem install bundler
	bundle config --local path vendor/bundle
	bundle install --binstubs

clean:
	rm -rf bin/ pkg/ stage/ vendor/

lint:
	bundle exec puppet-lint \
		--fail-on-warnings \
		--no-140chars-check \
		--no-autoloader_layout-check \
		--no-documentation-check \
		manifests/*.pp
	bundle exec rubocop --config .rubocop.yml Gemfile
	pdk validate metadata

package:
	pdk build --force

.PHONY: ci clean deps lint package
