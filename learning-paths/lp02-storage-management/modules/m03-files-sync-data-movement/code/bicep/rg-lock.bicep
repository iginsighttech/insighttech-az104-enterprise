targetScope = 'resourceGroup'

param lockName string = 'lock-rg-cannotdelete'
param lockNotes string = 'AZ-104 lab: prevent accidental deletion'

resource rgLock 'Microsoft.Authorization/locks@2016-09-01' = {
  name: lockName
  properties: {
    level: 'CanNotDelete'
    notes: lockNotes
  }
}
