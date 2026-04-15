targetScope = 'resourceGroup'

param groupObjectId string

var readerRoleDefinitionId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  'acdd72a7-3385-48ef-bd42-f606fba81ae7'
)

resource readerAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, groupObjectId, 'Reader')
  properties: {
    principalId: groupObjectId
    roleDefinitionId: readerRoleDefinitionId
    principalType: 'Group'
  }
}

output roleAssignmentId string = readerAssignment.id
