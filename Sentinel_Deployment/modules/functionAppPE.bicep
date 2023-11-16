param FunctionAppName string
param FunctionAppId string
param PrivateEndpointSubnetId string
param location string
param VnetId string

resource peFunctionApp 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: 'pe-${FunctionAppName}'
  location: location
  properties: { 
     subnet: {
      id: PrivateEndpointSubnetId
     }
     privateLinkServiceConnections: [
      {
        name: 'pe-${FunctionAppName}'
        properties: {
         privateLinkServiceId: FunctionAppId
         groupIds: [
          'sites'
         ] 
        }
      }
     ] 
  } 
}

resource privateDnsZoneFunctionApp 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azurewebsites.net'
  location: 'global'
}

resource privateDnsZoneLinkFunctionApp 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateDnsZoneFunctionApp.name}-link'
  parent: privateDnsZoneFunctionApp
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: VnetId
    }  
  }   
}

resource peDnsGroupFunctionApp 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-07-01' = {
  name: '${peFunctionApp.name}/dnsGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZoneFunctionApp.id
        } 
      }
    ]
  }
}
