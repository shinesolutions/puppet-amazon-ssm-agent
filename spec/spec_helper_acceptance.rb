require 'beaker_puppet_helpers'
require 'voxpupuli/acceptance/spec_helper_acceptance'

# beaker_puppet_helpers has no repo install step for Amazon Linux, although the
# OpenVox yum repo publishes <collection>-release-amazon-<version>.noarch.rpm
module AmazonReleaseRepo
  def install_puppet_release_repo_on(host, collection = 'puppet')
    variant, version, = host['packaging_platform'].split('-', 3)
    return super unless variant == 'amazon'

    repos = BeakerPuppetHelpers::InstallUtils::REPOS[implementation_from_collection(collection).to_sym][:release]
    host.install_package("#{repos[:yum]}/#{collection}-release-amazon-#{version}.noarch.rpm")
  end
end
BeakerPuppetHelpers::InstallUtils.singleton_class.prepend(AmazonReleaseRepo)

# configure_beaker installs the local module (and its metadata.json dependencies)
# on each host in before(:suite)
configure_beaker
