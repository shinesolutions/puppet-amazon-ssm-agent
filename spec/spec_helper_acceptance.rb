require 'voxpupuli/acceptance/spec_helper_acceptance'

# configure_beaker installs the local module (and its metadata.json dependencies)
# on each host in before(:suite). The agent comes from the nodesets' images
# (BEAKER_PUPPET_COLLECTION=preinstalled in the Makefile)
configure_beaker
