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

release-major:
	rtk release --release-increment-type major

release-minor:
	rtk release --release-increment-type minor

release-patch:
	rtk release --release-increment-type patch

release: release-minor

publish:
	pdk release publish --force --forge-token=$(forge_token)

.PHONY: ci clean deps lint package release release-major release-minor release-patch publish
