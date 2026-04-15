targetScope = 'subscription'

param location string = 'eastus2'
param rgName string
param groupObjectId string

param tags object = {
  Owner: 'student01'
  CostCenter: 'training'
  Environment: 'dev'
  Workload: 'az104'
  DataClass: 'training'
  ExpirationDate: '2026-12-31'
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
  tags: tags
}

module rgReaderAssignment 'rg-reader-assignment.bicep' = {
  name: 'assign-rg-reader'
  scope: rg
  params: {
    groupObjectId: groupObjectId
  }
}

output resourceGroupId string = rg.id
output roleAssignmentId string = rgReaderAssignment.outputs.roleAssignmentId
