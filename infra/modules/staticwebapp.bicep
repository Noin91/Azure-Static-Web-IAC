// Azure Static Web App. The SKU is locked to Free on purpose (cost guardrail):
// the @allowed decorator makes any other value fail at deployment time.
targetScope = 'resourceGroup'

@description('Name of the Static Web App.')
param name string

@description('Azure region of the resource.')
param location string

@description('Only Free is allowed. Standard costs money and is intentionally blocked.')
@allowed([
  'Free'
])
param skuName string = 'Free'

@description('Resource tags.')
param tags object = {}

resource staticWebApp 'Microsoft.Web/staticSites@2023-12-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuName
  }
  properties: {
    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true
  }
}

output id string = staticWebApp.id
output name string = staticWebApp.name
output defaultHostname string = staticWebApp.properties.defaultHostname
