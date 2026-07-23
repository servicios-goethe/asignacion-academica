targetScope = 'resourceGroup'

@description('Environment name')
@allowed([
  'dev'
  'prod'
])
param environment string

@description('Azure region')
param location string = resourceGroup().location

@description('Entra object id for the SQL administrator')
param sqlAdminObjectId string

@description('Temporary SQL server administrator login; disabled after Entra-only authentication is enabled')
param sqlServerAdminLogin string

@description('Entra login for the SQL administrator')
param entraAdminLogin string

@description('Temporary SQL administrator password. It is not stored by this template.')
@secure()
param sqlAdminPassword string

var tags = {
  Proyecto: 'asignacion-academica'
  Ambiente: environment
  Owner: 'servicios-goethe'
  GestionadoPor: 'Codex'
  CostCenter: 'asignacion-academica'
}
var suffix = environment == 'dev' ? 'dev' : 'prod'
var storageName = 'stgoetheasigacad${suffix}'
var keyVaultName = 'kv-goethe-asigacad-${suffix}'
var sqlServerName = 'sql-goethe-asigacad-${suffix}'
var sqlDatabaseName = 'sqldb-goethe-asigacad-${suffix}'
var logWorkspaceName = 'log-goethe-asigacad-${suffix}'
var appInsightsName = 'appi-goethe-asigacad-${suffix}'
var containerEnvironmentName = 'cae-goethe-asigacad-${suffix}'

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: 'Enabled'
    accessTier: 'Hot'
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storage
  name: 'default'
}

resource dataProtectionContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'dataprotection'
  properties: {
    publicAccess: 'None'
  }
}

resource exportsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'exports'
  properties: {
    publicAccess: 'None'
  }
}

resource keyVaultDev 'Microsoft.KeyVault/vaults@2023-07-01' = if (environment == 'dev') {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    publicNetworkAccess: 'Enabled'
    sku: {
      family: 'A'
      name: 'standard'
    }
  }
}

resource keyVaultProd 'Microsoft.KeyVault/vaults@2023-07-01' = if (environment == 'prod') {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    enablePurgeProtection: true
    publicNetworkAccess: 'Enabled'
    sku: {
      family: 'A'
      name: 'standard'
    }
  }
}

resource registry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: 'acrgoetheasigacad'
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logWorkspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logWorkspace.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    administratorLogin: sqlServerAdminLogin
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    publicNetworkAccess: 'Enabled'
    minimalTlsVersion: '1.2'
  }
}

resource sqlAdmin 'Microsoft.Sql/servers/administrators@2023-08-01-preview' = {
  parent: sqlServer
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: entraAdminLogin
    sid: sqlAdminObjectId
    tenantId: subscription().tenantId
  }
}

resource sqlAdOnly 'Microsoft.Sql/servers/azureADOnlyAuthentications@2023-08-01-preview' = {
  parent: sqlServer
  name: 'Default'
  dependsOn: [
    sqlAdmin
  ]
  properties: {
    azureADOnlyAuthentication: true
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
    zoneRedundant: false
    readScale: 'Disabled'
  }
}

resource containerEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: containerEnvironmentName
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logWorkspace.properties.customerId
        sharedKey: logWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

output storageAccountName string = storage.name
output keyVaultName string = environment == 'prod' ? keyVaultProd.name : keyVaultDev.name
output registryName string = registry.name
output sqlServerName string = sqlServer.name
output sqlDatabaseName string = sqlDatabase.name
output logWorkspaceName string = logWorkspace.name
output appInsightsName string = appInsights.name
output containerEnvironmentName string = containerEnvironment.name
