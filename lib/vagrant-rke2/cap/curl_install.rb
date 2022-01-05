
module VagrantPlugins
  module Rke2
    module Cap
      module Alpine
        module CurlInstall
          def self.curl_install(machine)
            machine.communicate.sudo("apk --quiet add --no-cache --no-progress curl")
          end
        end
      end
      module Debian
        module CurlInstall
          def self.curl_install(machine)
            machine.communicate.sudo("apt update -y -qq")
            machine.communicate.sudo("apt install -y -qq curl")
          end
        end
      end
      module Redhat
        module CurlInstall
          def self.curl_install(machine)
            machine.communicate.sudo <<~EOF
              if command -v dnf; then
                dnf -y install curl
              else
                yum -y install curl
              fi
            EOF
          end
        end
      end
      module Suse
        module CurlInstall
          def self.curl_install(machine)
            machine.communicate.sudo("zypper -n -q update")
            machine.communicate.sudo("zypper -n -q install curl")
          end
        end
      end
    end
  end
end