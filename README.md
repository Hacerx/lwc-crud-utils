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


---

## 📘 Types

All type definitions are located in [`src/typings/lwc/crudUtils.d.ts`](https://github.com/Hacerx/lwc-crud-utils/blob/master/src/typings/lwc/crudUtils.d.ts)

### `DMLResult`

| Property   | Type       | Required | Description                          |
|------------|------------|----------|--------------------------------------|
| `success`  | `boolean`  | ✅       | Operation status                     |
| `value`    | `string[]` | ✅       | Affected record IDs                  |
| `reason`   | `string`   | ✅       | Error message if `success` is false  |

### `SObject`

| Property | Type   | Required | Description                    |
|----------|--------|----------|--------------------------------|
| `Id`     | string | ✅       | Record ID                     |
| `[key]`  | any    | ❌       | Additional fields (dynamic)   |

### `RecordInput<T>`

| Property   | Type                        | Required | Description                     |
|------------|-----------------------------|----------|---------------------------------|
| `apiName`  | `string`                    | ✅       | API name of the object (e.g. `Account`) |
| `fields`   | `T` (object with key/values)| ✅       | Field data to insert            |

---

## 🧠 LWC Utility Function Parameters

The following functions are available from the module `c/crudUtils`:

### `deleteRecords(opts: DeleteRecordsOpts): Promise<DMLResult[]>`

| Parameter   | Type       | Required | Default | Description                                      |
|-------------|------------|----------|---------|--------------------------------------------------|
| `recordIds` | `string[]` | ✅       | –       | IDs of the records to delete (any SObject type) |
| `allOrNone` | `boolean`  | ❌       | `true`  | Whether the operation is atomic                 |

---

### `updateRecords<T>(opts: UpdateRecordsOpts<T>): Promise<DMLResult[]>`

| Parameter   | Type   | Required | Default | Description                                      |
|-------------|--------|----------|---------|--------------------------------------------------|
| `records`   | `T[]`  | ✅       | –       | Records to update (must include `Id`)           |
| `allOrNone` | `boolean` | ❌   | `true`  | Whether the operation is atomic                 |

---

### `insertRecords<T>(opts: InsertRecordsOpts<T>): Promise<DMLResult[]>`

| Parameter      | Type                   | Required | Default | Description                                                  |
|----------------|------------------------|----------|---------|--------------------------------------------------------------|
| `recordInputs` | `RecordInput<T>`       | ✅       | –       | List of object type + field values to insert                 |
| `allOrNone`    | `boolean`              | ❌       | `true`  | Whether the operation is atomic                              |

---

### `upsertRecords<T>(opts: UpsertRecordsOpts<T>): Promise<DMLResult[]>`

| Parameter     | Type           | Required | Default     | Description                                                   |
|---------------|----------------|----------|-------------|---------------------------------------------------------------|
| `records`     | `T[]`          | ✅       | –           | Records to upsert (must include `Id` or `externalId`)         |
| `apiName`     | `string`       | ✅       | –           | API name of the SObject                                      |
| `externalId`  | `string`       | ❌       | `'Id'`      | External ID field name                                       |
| `allOrNone`   | `boolean`      | ❌       | `true`      | Whether the operation is atomic                              |

---

### `getRecords<T>(opts: GetRecordsOpts): Promise<T[]>`

| Parameter      | Type        | Required | Default | Description                                                  |
|----------------|-------------|----------|---------|--------------------------------------------------------------|
| `apiName`      | `string`    | ✅       | –       | API name of the object to query                              |
| `fields`       | `string[]`  | ❌       | –       | Fields to retrieve                                           |
| `querySelect`  | `string`    | ❌       | –       | SOQL SELECT clause                                           |
| `orderBy`      | `string`    | ❌       | –       | SOQL ORDER BY clause                                         |
| `whereClause`  | `string`    | ❌       | –       | SOQL WHERE clause                                            |
| `queryLimit`   | `number`    | ❌       | –       | Maximum number of records to return                          |
