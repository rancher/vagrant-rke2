# frozen_string_literal: false

require "vagrant/util/line_buffer"
require 'vagrant/errors'
require 'yaml'

module VagrantPlugins
  module Rke2
    class Provisioner < Vagrant.plugin('2', :provisioner)
      def initialize(machine,config)
        super(machine,config)
        @logger = Log4r::Logger.new("vagrant::provisioners::rke2")
      end

      def provision
        @machine.ui.info "Guest Identity: %s" % @machine.config.vm.guest
        case @machine.config.vm.guest
        when :windows
          provisionWindows
        else
          provisionLinux
        end
      end
      
      def provisionLinux
        unless @machine.guest.capability(:curl_installed)
          @machine.ui.info 'Installing Curl ...'
          @machine.guest.capability(:curl_install)
        end

        cfg_file = config.config_path.to_s
        cfg_yaml = config.config.is_a?(String) ? config.config : config.config.transform_keys(&:to_s).to_yaml
        file_upload "rke2-config.yaml", cfg_file, cfg_yaml

        env_file = config.env_path.to_s
        env_text = ""
        if config.env.is_a?(String)
          env_text = config.env.to_s
        end
        if config.env.is_a?(Array)
          config.env.each {|line| env_text << "#{line.to_s}\n"}
        end
        file_upload "rke2-install.env", env_file, env_text

        capture = env_text.match(/INSTALL_RKE2_TYPE=([a-z]+)/)
        service = capture ? capture.captures[0] : ""

        prv_file = "/vagrant/rke2-provisioner.sh"
        prv_text = <<~EOF
          #! /usr/bin/env bash
          set -eu -o pipefail
          chown #{config.config_owner} #{config.config_path}
          chmod #{config.config_mode} #{config.config_path}
          chown #{config.env_owner} #{config.env_path}
          chmod #{config.env_mode} #{config.env_path}
          set -o allexport
          source #{config.env_path}
          set +o allexport
          curl -fsL '#{config.installer_url}' | sh -
        EOF
        file_upload("rke2-install.sh", prv_file, prv_text)
        @machine.ui.info "Invoking: #{prv_file}"
        @machine.communicate.sudo("chmod +x #{prv_file} && #{prv_file}", :error_key => :ssh_bad_exit_status_muted) do |type, line|
          @machine.ui.detail line, :color => :yellow
        end

        begin
          exe = "rke2"
          @machine.ui.info 'Checking the RKE2 version ...'
          @machine.communicate.execute("which rke2", :error_key => :ssh_bad_exit_status_muted) do |type, data|
            exe = data.chomp if type == :stdout
          end
        rescue Vagrant::Errors::VagrantError => e
          @machine.ui.detail "#{e.extra_data[:stderr].chomp}", :color => :red
        else
          @machine.communicate.sudo("#{exe} --version", :error_key => :ssh_bad_exit_status_muted) do |type, line|
            @machine.ui.detail line, :color => :yellow
          end
        end

        if config.install_path
          @machine.ui.info "Adding RKE2 to PATH and KUBECONFIG"
          outputs, handler = build_outputs
          begin
            @machine.communicate.sudo("echo 'export KUBECONFIG=/etc/rancher/rke2/rke2.yaml PATH=$PATH:/var/lib/rancher/rke2/bin' >> /home/vagrant/.bashrc", &handler)
            @machine.communicate.sudo("echo 'export KUBECONFIG=/etc/rancher/rke2/rke2.yaml PATH=$PATH:/var/lib/rancher/rke2/bin' >> /root/.bashrc", &handler)
          ensure
            outputs.values.map(&:close)
          end
        end

        @machine.ui.info "Starting RKE2 service..."
        if !service.empty?
          @machine.communicate.sudo("systemctl enable rke2-#{service}.service")
          if !config.skip_start
            @machine.communicate.sudo("systemctl restart rke2-#{service}.service") do |type, line|
              @machine.ui.detail line, :color => :yellow
            end
          end
        else
          @machine.communicate.sudo("systemctl enable rke2-server.service")
          if !config.skip_start 
            @machine.communicate.sudo("systemctl restart rke2-server.service") do |type, line|
              @machine.ui.detail line, :color => :yellow
            end
          end
         end
      end

      def provisionWindows 

        if config.config_path == DEFAULT_CONFIG_PATH_LINUX
          config.config_path = DEFAULT_CONFIG_PATH_WINDOWS
        end
        if config.installer_url == DEFAULT_INSTALLER_URL_LINUX
          config.installer_url = DEFAULT_INSTALLER_URL_WINDOWS     
        end

        config.installer_url

        scriptDir = File.expand_path('./cap/windows/scripts', File.dirname(__FILE__)) + "/"

        env_text = ""
        if config.env.is_a?(String)
          env_text = config.env
        end
        if config.env.is_a?(Array)
          config.env.each {|line| env_text << "-#{line.gsub("=", " ")} "}
        end

        containerScript = "install-containers-feature.ps1" 
        @machine.ui.info "Invoking: #{containerScript}"
  
        command = File.read(scriptDir + containerScript)
        @machine.communicate.execute(command, {shell: :powershell, elevated: true})
        @machine.guest.capability(:reboot)
        @machine.guest.capability(:wait_for_reboot)

        setupRke2 = "setup-rke2.ps1" 
        @machine.ui.info "Invoking: #{setupRke2}"
  
        command = File.read(scriptDir + setupRke2)
        command["!!INSTALL_URL!!"] = config.installer_url
        command["!!CONFIG_PATH!!"] = config.config_path
        command["!!CONFIG!!"] = config.config
        command["!!ENV!!"] = env_text
        @machine.communicate.execute(command, {shell: :powershell, elevated: true}) do |type, line|
          @machine.ui.detail line.chomp, :color => :yellow
        end

        if config.install_path
          setupPath = "setup-path.ps1" 
          @machine.ui.info "Invoking: #{setupPath}"
          command = File.read(scriptDir + setupPath)
          @machine.communicate.execute(command, {shell: :powershell, elevated: true}) do |type, line|
            @machine.ui.detail line.chomp, :color => :yellow
          end
        end

        @machine.ui.info "Checking RKE2 version:"
        @machine.communicate.test("Get-Command rke2", {shell: :powershell})
        @machine.communicate.execute('C:\usr\local\bin\rke2.exe --version', {shell: :powershell})  do |type, line|
          @machine.ui.detail line, :color => :yellow
        end

        @machine.ui.info "Starting RKE2 agent:"
        @machine.communicate.execute('C:\usr\local\bin\rke2.exe agent service --add', {shell: :powershell, elevated: true} )
        if !config.skip_start 
          @machine.communicate.execute("Start-Service -Name 'rke2'", {shell: :powershell, elevated: true} )
        end
        
      end

      def build_outputs
        outputs = {
          stdout: Vagrant::Util::LineBuffer.new { |line| handle_comm(:stdout, line) },
          stderr: Vagrant::Util::LineBuffer.new { |line| handle_comm(:stderr, line) },
        }
        block = proc { |type, data|
          outputs[type] << data if outputs[type]
        }
        [outputs, block]
      end

      # This handles outputting the communication line back to the UI
      def handle_comm(type, data)
        if [:stderr, :stdout].include?(type)
          # Output the line with the proper color based on the stream.
          options = {}
          options[:color] = type == :stdout ? :green : :red

          @machine.ui.detail(data.chomp, **options)
        end
      end

      def with_file(name, content)
        file = Tempfile.new([name])
        file.binmode
        begin
          file.write(content)
          file.fsync
          file.close
          yield file.path
        ensure
          file.close
          file.unlink
        end
      end

      def file_upload(local_file, remote_path, content)
        with_file(local_file, content) do |local_path|
          remote_tmp_dir = @machine.guest.capability :create_tmp_path, {:type => :directory}
          remote_tmp_path = [remote_tmp_dir, File.basename(remote_path)].join('/')
          @machine.communicate.upload(local_path, remote_tmp_path)
          if @machine.config.vm.guest != "windows"
            @machine.communicate.sudo("install -v -DTZ #{remote_tmp_path} #{remote_path}") do |type, line|
              @machine.ui.info line.chomp, :color => {:stderr => :red, :stdout => :default}[type]
            end
          end

        end
        @machine.ui.detail content.chomp, :color => :yellow
        remote_path
      end

      def quote_and_escape(text, quote = '"')
        "#{quote}#{text.to_s.gsub(/#{quote}/) { |m| "#{m}\\#{m}#{m}" }}#{quote}"
      end
    end
  end
end
