// Monthly cost budget on subscription scope with early warning alerts.
// A budget only sends notifications. It doesnt stop or delete resources.
targetScope = 'subscription'

@description('Budget amount in the subscription.')
param amount int

@description('First day of the budget period (yyyy-MM-dd, must be the 1st of a month).')
param startDate string

@description('Emain alert receiver.')
param contactEmail string

resource budget 'Microsoft.Consumption/budgets@2023-05-01' = {
  name: 'budget-sub-monthly'
  properties: {
    category: 'Cost'
    amount: amount
    timeGrain: 'Monthly'
    timePeriod: {
      startDate: startDate
    }
    notifications: {
      actual50: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: 50
        thresholdType: 'Actual'
        contactEmails: [
          contactEmail
        ]
      }
      actual90: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: 90
        thresholdType: 'Actual'
        contactEmails: [
          contactEmail
        ]
      }
      actual100: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: 100
        thresholdType: 'Actual'
        contactEmails: [
          contactEmail
        ]
      }
    }
  }
}

output name string = budget.name
