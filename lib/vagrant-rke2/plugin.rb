# frozen_string_literal: true

require_relative 'version'

module VagrantPlugins
  module Rke2
    class Plugin < Vagrant.plugin(2)
      name 'rke2'

      config(:rke2, :provisioner) do
        require_relative 'config'
        Config
      end

      provisioner(:rke2) do
        require_relative 'provisioner'
        Provisioner
      end

      guest_capability(:linux, :rke2_installed) do
        require_relative "cap/linux/rke2_installed"
        Cap::Linux::Rke2Installed
      end

      guest_capability(:linux, :curl_installed) do
        require_relative "cap/linux/curl_installed"
        Cap::Linux::CurlInstalled
      end

      guest_capability(:alpine, :curl_install) do
        require_relative "cap/curl_install"
        Cap::Alpine::CurlInstall
      end

      guest_capability(:debian, :curl_install) do
        require_relative "cap/curl_install"
        Cap::Debian::CurlInstall
      end

      guest_capability(:redhat, :curl_install) do
        require_relative "cap/curl_install"
        Cap::Redhat::CurlInstall
      end

      guest_capability(:suse, :curl_install) do
        require_relative "cap/curl_install"
        Cap::Suse::CurlInstall
      end
    
      guest_capability(:windows, :rke2_installed) do
        require_relative "cap/windows/rke2_installed"
        Cap::Windows::Rke2Installed
      end
    end
  end
end
