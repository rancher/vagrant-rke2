# frozen_string_literal: true

module Vagrant
    module Rke2
      class Config < Vagrant.plugin(2, :config)
        DEFAULT_FILE_MODE = '0600'
        DEFAULT_FILE_OWNER = 'root:root'
        DEFAULT_CONFIG_MODE = DEFAULT_FILE_MODE
        DEFAULT_CONFIG_OWNER = DEFAULT_FILE_OWNER
        DEFAULT_CONFIG_PATH = '/etc/rancher/rke2/config.yaml'
        DEFAULT_ENV_MODE = DEFAULT_FILE_MODE
        DEFAULT_ENV_OWNER = DEFAULT_FILE_OWNER
        DEFAULT_ENV_PATH = '/etc/rancher/rke2/install.env'
        DEFAULT_INSTALLER_URL = 'https://get.rke2.io'
  
        # string or array
        # @return [Array<String>]
        attr_accessor :args
  
        # string (.yaml) or hash
        # @return [Hash]
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
  
        # string (.env), array, or hash
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
  
        def initialize
          @args = UNSET_VALUE
          @config = UNSET_VALUE
          @config_mode = UNSET_VALUE
          @config_owner = UNSET_VALUE
          @config_path = UNSET_VALUE
          @env = UNSET_VALUE
          @env_mode = UNSET_VALUE
          @env_owner = UNSET_VALUE
          @env_path = UNSET_VALUE
          @installer_url = UNSET_VALUE
        end
  
        def finalize!
          @args = [] if @args == UNSET_VALUE
          @config = "" if @config == UNSET_VALUE
          @config_mode = @config_mode == UNSET_VALUE ? DEFAULT_CONFIG_MODE : @config_mode.to_s
          @config_owner = @config_owner == UNSET_VALUE ? DEFAULT_CONFIG_OWNER : @config_owner.to_s
          @config_path = @config_path == UNSET_VALUE ? DEFAULT_CONFIG_PATH : @config_path.to_s
          @env = [] if @env == UNSET_VALUE
          @env_mode = DEFAULT_ENV_MODE if @env_mode == UNSET_VALUE
          @env_owner = DEFAULT_ENV_OWNER if @env_owner == UNSET_VALUE
          @env_path = DEFAULT_ENV_PATH if @env_path == UNSET_VALUE
          @installer_url = DEFAULT_INSTALLER_URL if @installer_url == UNSET_VALUE
  
          if @args && args_valid?
            @args = @args.is_a?(Array) ? @args.map { |a| a.to_s } : @args.to_s
          end
        end
  
        def validate(machine)
          errors = _detected_errors
  
          unless args_valid?
            errors << "Rke2 provisioner `args` must be an array or string."
          end
  
          unless config_valid?
            errors << "Rke2 provisioner `config` must be a hash or string (yaml)."
          end
  
          unless env_valid?
            errors << "Rke2 provisioner `env` must be an array, hash, or string."
          end
  
          { "rke2 provisioner" => errors }
        end
  
        def args_valid?
          return true unless args
          return true if args.is_a?(String)
          return true if args.is_a?(Integer)
          if args.is_a?(Array)
            args.each do |a|
              return false if !a.kind_of?(String) && !a.kind_of?(Integer)
            end
            return true
          end
          false
        end
  
        def config_valid?
          return true unless args
          return true if config.is_a?(String)
          return true if config.is_a?(Hash)
          false
        end
  
        def env_valid?
          return true unless env
          return true if env.is_a?(String)
          return true if env.is_a?(Hash)
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
  