import deleteApexRecords from "@salesforce/apex/LwcCrudUtils.deleteRecords";
import updateApexRecords from "@salesforce/apex/LwcCrudUtils.updateRecords";
import insertApexRecords from "@salesforce/apex/LwcCrudUtils.insertRecords";
import upsertApexRecords from "@salesforce/apex/LwcCrudUtils.upsertRecords";
import getApexRecords from "@salesforce/apex/LwcCrudUtils.getRecords";

/**
 * Bulk delete records using Apex.
 * @param {DeleteRecordsOpts} opts
 * @returns {Promise<DMLResult[]>}
 */
export function deleteRecords({ recordIds, allOrNone = true }) {
    return deleteApexRecords({ recordIds, allOrNone });
}

/**
 * Bulk update records using Apex.
 * @template T
 * @param {UpdateRecordsOpts<T>} opts
 * @returns {Promise<DMLResult[]>}
 */
export function updateRecords({ records, allOrNone = true }) {
    return updateApexRecords({ records, allOrNone });
}

/**
 * Bulk insert records using Apex.
 * @template T
 * @param {InsertRecordsOpts<T>} opts
 * @returns {Promise<DMLResult[]>}
 */
export function insertRecords({ recordInputs, allOrNone = true }) {
    return insertApexRecords({ recordInputs, allOrNone });
}

/**
 * Bulk upsert records using Apex.
 * @template T
 * @param {UpsertRecordsOpts<T>} opts
 * @returns {Promise<DMLResult[]>}
 */
export function upsertRecords({ records, apiName, externalId = 'Id', allOrNone = true }) {
    return upsertApexRecords({ records, apiName, externalId, allOrNone });
}

/**
 * Get records using Apex.
 * ⚠️ This method is unsfe, you should create an specific method for your use case
 * @template T
 * @param {GetRecordsOpts} opts
 * @returns {Promise<T[]>}
 */
export function getRecords({ fields=[], querySelect='', apiName='', whereClause='', orderBy='', queryLimit=null }) {
    return getApexRecords({ fields, querySelect, apiName, whereClause, orderBy, queryLimit });
}