// Copyright (c) Microsoft. All rights reserved.

param apiManagementServiceName string
param keyVaultName string
param aoaiName string
param webAppName string

resource apiManagementService 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apiManagementServiceName
}

resource aoai 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' existing = {
  name: aoaiName
}

resource webApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webAppName
}

resource aoaiKeyNamedValue 'Microsoft.ApiManagement/service/namedValues@2023-03-01-preview' = {
  name: aoaiName
  parent: apiManagementService
  properties: {
    displayName: aoaiName
    keyVault: {
      identityClientId: null
      secretIdentifier: 'https://${keyVaultName}${environment().suffixes.keyvaultDns}/secrets/${aoaiName}'
    }
    secret: true
  }
}

resource backendNamedValue 'Microsoft.ApiManagement/service/namedValues@2023-03-01-preview' = {
  name: 'backend-${aoaiName}'
  parent: apiManagementService
  properties: {
    displayName: 'backend-${aoaiName}'
    value: '${aoai.properties.endpoint}openai/'
    secret: false
  }
}

resource backend 'Microsoft.ApiManagement/service/backends@2023-03-01-preview' = {
  name: webAppName
  parent: apiManagementService
  properties: {
    protocol: 'http'
    url: 'https://${webApp.properties.defaultHostName}/openai/'
  }
}
