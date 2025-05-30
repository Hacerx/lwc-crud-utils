declare module "c/crudUtils" {
    export function deleteRecords(opts: DeleteRecordsOpts): Promise<DMLResult[]>;
    export function updateRecords<T = SObject>(opts: UpdateRecordsOpts<T>): Promise<DMLResult[]>;
    export function insertRecords<T = SObject>(opts: InsertRecordsOpts<T>): Promise<DMLResult[]>;
    export function upsertRecords<T = SObject>(opts: UpsertRecordsOpts<T>): Promise<DMLResult[]>;
}

type DeleteRecordsOpts = {
    /**
     * The IDs of the records to delete.
     * The IDs can be provided from different SObjects.
     * @example ['001xx000003DGXAAA4', '001xx000003DGYAAA4']
     */
    recordIds: string[];
    /**
     * If all records must succeed or fail together.
     * @default true
     */
    allOrNone?: boolean;
}

type UpdateRecordsOpts<T=SObject> = {
    /**
     * The records to update.
     * Each record must have an Id field.
     * It can update different SObjects together.
     * @example [{ Id: '001xx000003DGXAAA4', Name: 'Updated Account' }, { Id: '001xx000003DGYAAA4', Name: 'Another Updated Account' }]
     */
    records: T[];
    /**
     * If all records must succeed or fail together.
     * @default true
     */
    allOrNone?: boolean;
}

type InsertRecordsOpts<T=SObject> = {
    /**
     * Api name and fields of the record to insert.
     * Each record must have an apiName and fields.
     * It can insert different SObjects together.
     * @example [{ apiName: 'Account', fields: { Name: 'Acme Corp', Industry: 'Technology' } }]
     */
    recordInputs: RecordInput<T>;
    /**
     * If all records must succeed or fail together.
     * @default true
     */
    allOrNone?: boolean;
}

type UpsertRecordsOpts<T=SObject> = {
    /**
     * The records to upsert.
     * Each record must have an Id field or the externalId field.
     * It can upsert different SObjects together.
     * @example [{ Id: '001xx000003DGXAAA4', Name: 'Updated Account' }, { Name: 'New Account', ExternalId__c: '12345' }]
     */
    records: T[];
    /**
     * The API name of the SObject to upsert.
     */
    apiName: string;
    /**
     * The external ID field to use for upsert.
     * This field must be unique across all records.
     * @example 'ExternalId__c'
     * @default 'Id'
     */
    externalId?: string;
    /**
     * If all records must succeed or fail together.
     * @default true
     */
    allOrNone?: boolean;
}
