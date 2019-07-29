module TopologicalInventory
  module Azure
    class Collector
      module Compute
        def source_regions(scope)
          all_subscriptions_connection.subscriptions.list_locations(scope[:subscription_id]).value
        end

        # def resource_groups
        #   @resource_groups ||= resources_connection(scope).resource_groups.list
        # end

        def flavors(scope)
          compute_provider = resources_connection(scope).providers.get('Microsoft.Compute')
          provider_region = compute_provider&.resource_types&.first&.locations&.first.delete("\s").downcase

          compute_connection(scope).virtual_machine_sizes.list(provider_region).value
        end

        def vms(scope)
          resources_connection(scope).resources.list(:filter => "resourceType eq 'Microsoft.Compute/virtualMachines'").map do |vm|
            vm = compute_connection(scope).virtual_machines.get(resource_group_name(vm.id), vm.name, :expand => 'instanceView')

            network_interfaces = vm.network_profile.network_interfaces.map do |x|
              network_connection(scope).network_interfaces.get(resource_group_name(x.id), network_interface_name(x.id))
            end

            {:vm => vm, :network_interfaces => network_interfaces}
          end
        end

        def volumes(scope)
          compute_connection(scope).disks.list
        end

        # def orchestration_stacks
        #   resource_groups.flat_map do |group|
        #     # Old API names it 'list', recent versions name it 'list_by_resource_group'
        #     meth = resources_connection(scope).deployments.respond_to?(:list_by_resource_group) ? :list_by_resource_group : :list
        #     resources_connection(scope).deployments.send(meth, group.name).map do |deployment|
        #       [
        #         group,                                                                   # resource group
        #         deployment,                                                              # deployment
        #         resources_connection(scope).deployment_operations.list(group.name, deployment.name)  # operations of the deployment
        #       ]
        #     end
        #   end
        # end
        #
      end
    end
  end
end
