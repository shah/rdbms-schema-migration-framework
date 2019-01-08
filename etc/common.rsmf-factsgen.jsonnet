{
  osQueries: {
    singleRow : [
      { name: "system-localhost", query: "select * from system_info" },
      { name: "eth0-interface-localhost", query: "select * from interface_addresses where interface = 'eth0'" }
    ],
    multipleRows : [
      { name: "interfaces-localhost", query: "select * from interface_addresses" }
    ],
  },

  shellEvals: 
  [
    // TODO: this was copied from CCF, needs to be updated for RSMF

    // The dockerHostIPAddress value is useful when the migration needs to know its externally-facing IP address.
    // Use it like this:
    //     local dockerFacts = import "docker-localhost.rsmf-facts.json";
    //     static_configs: [ { targets: [dockerFacts.dockerHostIPAddress + ":9100"] } ]
    //{ name: "docker-localhost", key: "dockerHostIPAddress", evalAsTextValue: "/sbin/ip -4 -o addr show dev eth0| awk '{split(\\$4,a,\\\"/\\\");print a[1]}'" },

    // The dockerBridgeNetworkGatewayIPAddress value is useful for docker-compose.yml extra_hosts (e.g. --add-host) 
    // when one migration needs to reference another migration on the same docker host. Use it like this:
    //     local dockerFacts = import "docker-localhost.rsmf-facts.json";
    //     extra_hosts: ["other_migration" + ':' + dockerFacts.dockerBridgeNetworkGatewayIPAddress],
    //{ name: "docker-localhost", key: "dockerBridgeNetworkGatewayIPAddress", evalAsTextValue: "docker network inspect --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}' bridge" },
  ],
}