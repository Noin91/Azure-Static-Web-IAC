using './main.bicep'

param workload = 'fantasy-e-draft'

// Use dev for a first validation run, so it does not collide with manually created resources.
param env = 'dev'
param location = 'centralus'
param budgetAmount = 1
param budgetStartDate = '2026-11-01'

//   export BUDGET_CONTACT_EMAIL="my@email.de"
param budgetContactEmail = readEnvironmentVariable('BUDGET_CONTACT_EMAIL')
