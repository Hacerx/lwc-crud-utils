# ⚡ LWC CRUD Utilities for Salesforce

This project provides a reusable set of LWC utilities to simplify performing **batch CRUD operations** (Create, Read, Update, Delete) on Salesforce records using Apex methods.

Designed for Salesforce developers who need to handle **multiple records at once**, this utility is great for admin tools, mass data updates, and dynamic form-based interfaces.

---

## 📦 Features

- 📝 Insert multiple records dynamically (different type of objects simultaneously)
- 🔄 Update multiple records in a batch (different type of objects simultaneously)
- ❌ Delete multiple records by ID (different type of objects simultaneously)
- 🪄 Upsert multiple records by external id (one type of object, limited by externalId)
- 🔍 Retrieve multiple records with dynamic fields (⚠️ This method is unsfe, you should create an specific method for your use case)
- ✅ Supports `allOrNone` transactions
- 💡 Type-safe interfaces for cleaner and safer code

---

## 🔧 Installation

```bash
sf project deploy start -x ./manifest/package.xml -l RunSpecifiedTests -t LwcCrudUtilsTest
```

---

## 🚀 Example of usage
```js
import { LightningElement } from 'lwc';
import { deleteRecords, updateRecords, insertRecords, upsertRecords, getRecords } from 'c/crudUtils';

export default class AuxHacerx extends LightningElement {
  async handleInsert() {
    const inputs = [
      {
        apiName: 'Account',
        fields: {
          Name: 'Acme Corp',
          Industry: 'Technology'
        }
      },
      {
        apiName: 'Account',
        fields: {
          Name: 'Globex Inc',
          Industry: 'Finance'
        }
      }
    ];

    const result = await insertRecords({ recordInputs: inputs, allOrNone: true });
    console.log('Insert Results:', result);
  }

  async handleUpdate() {
    const records = [
      { Id: '001XXXXXXXXXXXXAAA', Name: 'Updated Account A' },
      { Id: '001XXXXXXXXXXXXBBB', Name: 'Updated Account B' }
    ];

    const result = await updateRecords({ records, allOrNone: false });
    console.log('Update Results:', result);
  }

  async handleDelete() {
    const idsToDelete = ['001XXXXXXXXXXXXAAA', '001XXXXXXXXXXXXBBB'];

    const result = await deleteRecords({ recordIds: idsToDelete, allOrNone: true });
    console.log('Delete Results:', result);
  }

  async handleUpsert() {
    const records = [
      { External_Id__c: 'ext789', Name: 'John' },
      { External_Id__c: 'ext101', Name: 'Jane' }
    ];

    const result = await upsertRecords({ records, apiName: 'Account', externalId: 'External_Id__c', allOrNone: false });
    console.log('Upsert Results:', result);
  }

  async handleGetRecords() {
    const account = await getRecords({ apiName: 'Account', fields: ['Id', 'Name'] })
  }
}
```