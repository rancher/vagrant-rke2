# frozen_string_literal: true

module VagrantPlugins
    module Rke2
      class Config < Vagrant.plugin(2, :config)
        DEFAULT_FILE_MODE = '0600'
        DEFAULT_FILE_OWNER = 'root:root'
        DEFAULT_CONFIG_MODE = DEFAULT_FILE_MODE
        DEFAULT_CONFIG_OWNER = DEFAULT_FILE_OWNER
        DEFAULT_CONFIG_PATH_LINUX = '/etc/rancher/rke2/config.yaml'
        DEFAULT_CONFIG_PATH_WINDOWS = 'C:/etc/rancher/rke2/config.yaml'
        DEFAULT_ENV_MODE = DEFAULT_FILE_MODE
        DEFAULT_ENV_OWNER = DEFAULT_FILE_OWNER
        DEFAULT_ENV_PATH = '/etc/rancher/rke2/install.env'
        DEFAULT_INSTALLER_URL = 'https://get.rke2.io'
  
        # string (.yaml)
        # @return [String]
        attr_accessor :config
  
        # Defaults to `0600`
        # @return [String]
        attr_accessor :config_mode
  
        # Defaults to `root:root`
        # @return [String]
        attr_accessor :config_owner
  
        # Defaults to `/etc/rancher/rke2/config.yaml`
        # @return [String]
        attr_accessor :config_path
  
        # string (.env) or array
        # @return [Array<String>]
        attr_accessor :env
  
        # Defaults to `0600`
        # @return [String]
        attr_accessor :env_mode
  
        # Defaults to `root:root`
        # @return [String]
        attr_accessor :env_owner
  
        # Defaults to `/etc/rancher/rke2/install.env`
        # @return [String]
        attr_accessor :env_path
  
        # Defaults to `https://get.rke2.io`
        # @return [String]
        attr_accessor :installer_url
  
        # Defaults to true
        # @return [Boolean]
        attr_accessor :install_kubectl

        def initialize
          @config = UNSET_VALUE
          @config_mode = UNSET_VALUE
          @config_owner = UNSET_VALUE
          @config_path = UNSET_VALUE
          @env = UNSET_VALUE
          @env_mode = UNSET_VALUE
          @env_owner = UNSET_VALUE
          @env_path = UNSET_VALUE
          @installer_url = UNSET_VALUE
          @install_kubectl = UNSET_VALUE
        end
  
        def finalize!
          @config = "" if @config == UNSET_VALUE
          @config_mode = @config_mode == UNSET_VALUE ? DEFAULT_CONFIG_MODE : @config_mode.to_s
          @config_owner = @config_owner == UNSET_VALUE ? DEFAULT_CONFIG_OWNER : @config_owner.to_s
          @config_path = @config_path == UNSET_VALUE ? DEFAULT_CONFIG_PATH_LINUX : @config_path.to_s
          @env = [] if @env == UNSET_VALUE
          @env_mode = DEFAULT_ENV_MODE if @env_mode == UNSET_VALUE
          @env_owner = DEFAULT_ENV_OWNER if @env_owner == UNSET_VALUE
          @env_path = DEFAULT_ENV_PATH if @env_path == UNSET_VALUE
          @installer_url = DEFAULT_INSTALLER_URL if @installer_url == UNSET_VALUE
          @install_kubectl = true if @install_kubectl == UNSET_VALUE
        end
  
        def validate(machine)
          errors = _detected_errors
  
          unless config_valid?
            errors << "Rke2 provisioner `config` must be a string (yaml)."
          end
  
          unless env_valid?
            errors << "Rke2 provisioner `env` must be an array or string."
          end
  
          { "rke2 provisioner" => errors }
        end
  
        def config_valid?
          return true if config.is_a?(String)
          false
        end
  
        def env_valid?
          return true unless env
          return true if env.is_a?(String)
          if env.is_a?(Array)
            env.each do |a|
              return false unless a.kind_of?(String)
            end
            return true
          end
          false
        end
      end
    end
  end
  