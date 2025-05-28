type DMLResult = {
  success: boolean;
  value: string[];
  reason: string;
}

type SObject = {
  Id: string;
  [key: string]: any; // Allow any other properties
}

type RecordInput<T = { [key: string]: any }> = {
  apiName: string;
  fields: T; // Allow any field with any value
}

declare module "@salesforce/apex/LwcCrudUtils.deleteRecords" {
  export default function deleteRecords(param: {recordIds: string[], allOrNone: boolean}): Promise<DMLResult[]>;
}
declare module "@salesforce/apex/LwcCrudUtils.updateRecords" {
  export default function updateRecords<T=SObject>(param: {records: T[], allOrNone: boolean}): Promise<DMLResult[]>;
}
declare module "@salesforce/apex/LwcCrudUtils.insertRecords" {
  export default function insertRecords<T=SObject>(param: {recordInputs: RecordInput<T>, allOrNone: boolean}): Promise<DMLResult[]>;
}
