# frozen_string_literal: true

module VagrantPlugins
    module Rke2
      module Cap
        module Linux
          module Rke2Installed
            # Check if RKE2 is installed.
            # @return [true, false]
            def self.rke2_installed(machine)
              machine.communicate.test("which rke2", sudo: true)
            end
          end
        end
      end
    end
  end
  