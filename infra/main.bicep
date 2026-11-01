// Subscription-scope deployment: resource group + Static Web App (Free) + monthly budget.
targetScope = 'subscription'

@description('Workload name used in resource names.')
param workload string = 'fantasy-e-draft'

@description('Environment suffix used in resource names and tags.')
@allowed([
  'dev'
  'test'
  'prod'
])
param env string = 'prod'

@description('Region of the resource group and the Static Web App resource (content itself is served globally).')
@allowed([
  'westeurope'
  'westus2'
  'centralus'
  'eastus2'
  'eastasia'
])
param location string = 'westeurope'

@description('Owner tag value.')
param owner string = 'dennis'

@description('Monthly budget in the subscription currency. Alerts only, a budget never stops resources.')
@minValue(1)
param budgetAmount int = 1

@description('First day of the budget period (yyyy-MM-dd, must be the 1st of a month).')
param budgetStartDate string

@description('E-mail address for budget alerts.')
param budgetContactEmail string

var tags = {
  project: workload
  environment: env
  owner: owner
  managedBy: 'bicep'
}

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${workload}-${env}'
  location: location
  tags: tags
}

module staticWebApp 'modules/staticwebapp.bicep' = {
  name: 'deploy-stapp-${workload}-${env}'
  scope: rg
  params: {
    name: 'stapp-${workload}-${env}'
    location: location
    tags: tags
  }
}

module budget 'modules/budget.bicep' = {
  name: 'deploy-budget-sub-monthly'
  params: {
    amount: budgetAmount
    startDate: budgetStartDate
    contactEmail: budgetContactEmail
  }
}

output resourceGroupName string = rg.name
output staticWebAppName string = staticWebApp.outputs.name
output staticWebAppHostname string = staticWebApp.outputs.defaultHostname
