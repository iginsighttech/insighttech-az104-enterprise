targetScope = 'subscription'

param rgName string

var requireEnvTagPolicyName = 'require-env-tag-rg'
var requireEnvAssignmentName = 'assign-require-env-tag-audit'

resource policyDef 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: requireEnvTagPolicyName
  properties: {
    displayName: 'Require Environment tag on resource groups'
    policyType: 'Custom'
    mode: 'All'
    description: 'Ensures RGs have a non-empty Environment tag.'
    parameters: {
      effect: {
        type: 'String'
        allowedValues: [
          'Audit'
          'Deny'
        ]
        defaultValue: 'Audit'
      }
    }
    policyRule: {
      if: {
        allOf: [
          { field: 'type', equals: 'Microsoft.Resources/subscriptions/resourceGroups' }
          {
            anyOf: [
              { field: 'tags["Environment"]', exists: false }
              { field: 'tags["Environment"]', equals: '' }
            ]
          }
        ]
      }
      then: { effect: '[parameters("effect")]' }
    }
  }
}

resource policyAssign 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: requireEnvAssignmentName
  properties: {
    displayName: 'Require Environment tag on RGs (Audit)'
    policyDefinitionId: policyDef.id
    parameters: {
      effect: { value: 'Audit' }
    }
  }
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  name: rgName
}

module rgLock 'rg-lock.bicep' = {
  name: 'apply-rg-cannotdelete-lock'
  scope: rg
  params: {
    lockName: 'lock-rg-cannotdelete'
    lockNotes: 'AZ-104 lab: prevent accidental deletion'
  }
}
