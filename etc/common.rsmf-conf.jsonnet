local systemFacts = import "system-localhost.rsmf-facts.json";

{
  domainName: 'appliance.local',
  defaultDockerNetworkName : 'appliance',
  
  applianceName: systemFacts.hostname,
  applianceHostName: $.applianceName,
  applianceFQDN: $.applianceHostName + '.' + $.domainName,
}