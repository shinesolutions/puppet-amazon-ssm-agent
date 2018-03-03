ci: tools clean deps lint

deps:
	gem install bundler
	rm -rf .bundle
	bundle install --binstubs

clean:
	rm -rf pkg
	rm -f Gemfile.lock

lint:
	puppet-lint \
		--fail-on-warnings \
		--no-140chars-check \
		--no-autoloader_layout-check \
		--no-documentation-check \
		manifests/*.pp

package:
	puppet module build .

tools:
	gem install puppet puppet-lint r10k

.PHONY: ci clean deps lint package tools
