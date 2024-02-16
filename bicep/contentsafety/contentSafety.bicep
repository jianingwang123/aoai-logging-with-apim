// Copyright (c) Microsoft. All rights reserved.

param keyVaultName string
param contentSafetyAccountName string
param privateEndpointName string
param location string
param vnetName string
param subnetName string

resource vault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource contentSafety 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: contentSafetyAccountName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'ContentSafety'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: contentSafetyAccountName
    publicNetworkAccess: 'Disabled'
  }
}

module privateEndpoint '../network/privateEndpoint.bicep' = {
  name: '${contentSafetyAccountName}-privateEndpoint'
  params: {
    groupIds: [
      'account'
    ]
    dnsZoneName: 'privatelink.cognitiveservices.azure.com'
    name: privateEndpointName
    subnetName: subnetName
    privateLinkServiceId: contentSafety.id
    vnetName: vnetName
    location: location
  }
}

resource contentSafetyKey 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: contentSafetyAccountName
  parent: vault
  properties: {
    attributes: {
      enabled: true
    }
    contentType: 'string'
    value: contentSafety.listKeys().key1
  }
}
