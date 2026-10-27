# Cheapest checks first: lint-extra (seconds), test (lint, validate, unit specs), acceptance (minutes), package
ci: clean deps lint-extra test acceptance package

deps:
	gem install bundler --version=4.0.22
	bundle install

clean:
	rm -rf bin/ pkg/ stage/ vendor/

# lint, validate (syntax, metadata_lint), unit specs and static checks.
# safe.directory lets the git-based checks run as root in the buildenv container
test:
	GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=safe.directory GIT_CONFIG_VALUE_0=$(CURDIR) \
		bundle exec rake test

# All static checks, without the unit specs
lint: lint-extra
	bundle exec rake lint syntax metadata_lint

# The static checks rake test doesn't run (its check task skips misplaced_files and utf8),
# so ci runs them without repeating rake test's lint/syntax/metadata_lint.
# yamllint and markdownlint cover every hand-written YAML and Markdown file,
# except CHANGELOG.md, which rtk release rewrites in its own layout
lint-extra:
	bundle exec rake rubocop check:misplaced_files check:utf8
	yamllint .yamllint.yaml .fixtures.yml .markdownlint.yaml .rubocop.yml hiera.yaml data/*.yaml data/*/*.yaml .github/workflows/*.yaml spec/default_facts.yml spec/acceptance/nodesets/*.yml
	markdownlint-cli2 README.md .github/ISSUE_TEMPLATE/*.md
	python3 -m json.tool .rtk.json

# Run acceptance tests against every nodeset; beaker only runs one per invocation.
# BEAKER_PUPPET_COLLECTION=preinstalled because the nodesets' images already have the
# OpenVox 9 agent; otherwise configure_beaker installs the release repo and agent again
acceptance:
	set -e; for nodeset in spec/acceptance/nodesets/*.yml; do \
		echo "== $$nodeset"; \
		BEAKER_PUPPET_COLLECTION=preinstalled BEAKER_SETFILE=$$nodeset bundle exec rake beaker; \
	done

# Generate the HTML reference in docs/
docs:
	bundle exec rake "strings:generate[,,,,,,--output-dir docs]"

package: deps
	bundle exec rake module:build

release:
	rtk release

# Check the module is ready to publish to the Puppet Forge; reports what is missing.
# safe.directory lets the git-based checks run as root in the buildenv container
publish-check: package
	GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=safe.directory GIT_CONFIG_VALUE_0=$(CURDIR) \
		tools/publish-check

# Publish the built package to the Puppet Forge, run by the publish workflow on a pushed tag.
# Requires BLACKSMITH_FORGE_API_KEY (a Forge API key) and a passing publish-check
publish: publish-check
	bundle exec rake module:push

.PHONY: ci deps clean test lint lint-extra acceptance docs package release publish-check publish
