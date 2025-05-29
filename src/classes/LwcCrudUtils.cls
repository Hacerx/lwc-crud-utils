public with sharing class LwcCrudUtils {

    /**
     * Generate AuraHandledException
     * Workaround for AuraHandledException not being serializable
     * @param message Exception message
     */
    private static void generateAuraException(String message) {
        AuraHandledException ex = new AuraHandledException(message);
        ex.setMessage(message);
        throw ex;
    }

    private static List<SObject> getSObjectList(List<RecordInput> recordInputs) {
        List<SObject> records = new List<SObject>();

        for(RecordInput recordInput : recordInputs) {
            records.add((SObject)JSON.deserialize(JSON.serialize(recordInput.fields), Type.forName(recordInput.apiName)));
        }

        return records;
    }

    /**
     * Delete records
     * @param recordIds List of record Ids to delete
     * @param allOrNone If true, all records must be deleted successfully or none will be deleted
     * @return List of DMLResult objects containing the result of each delete operation
     */
    @AuraEnabled
    public static List<DMLResult> deleteRecords(List<Id> recordIds, Boolean allOrNone){
        List<DMLResult> dmlResults = new List<DMLResult>();

        /**
         * Check if recordIds is null or empty
         */
        if(recordIds == null || recordIds.isEmpty()){
            return dmlResults;
        }

        try{
            List<Database.DeleteResult> results = Database.delete(recordIds, allOrNone, AccessLevel.USER_MODE);

            for(Database.DeleteResult result : results){
                dmlResults.add(new DMLResult(result));
            }

        }catch(Exception e){
            generateAuraException('Error deleting records, please contact with your admin');
        }

        return dmlResults;
    }

    /**
     * Update records
     * @param records List of records to update
     * @param allOrNone If true, all records must be updated successfully or none will be updated
     */
    @AuraEnabled
    public static List<DMLResult> updateRecords(List<SObject> records, Boolean allOrNone){
        List<DMLResult> dmlResults = new List<DMLResult>();

        /**
         * Check if records is null or empty
         */
        if(records == null || records.isEmpty()){
            return dmlResults;
        }

        try{
            List<Database.SaveResult> results = Database.update(records, allOrNone, AccessLevel.USER_MODE);

            for(Database.SaveResult result : results){
                dmlResults.add(new DMLResult(result));
            }

        }catch(Exception e){
            generateAuraException('Error updating records, please contact with your admin');
        }

        return dmlResults;
    }

    public class RecordInput {
        @AuraEnabled
        public String apiName { get; set; }
        @AuraEnabled
        public Object fields { get; set; }

        public RecordInput(String apiName, Object fields) {
            this.apiName = apiName;
            this.fields = fields;
        }
    }

    /**
     * Insert records
     * @param records List of records to insert
     * @param allOrNone If true, all records must be inserted successfully or none will be inserted
     */
    @AuraEnabled
    public static List<DMLResult> insertRecords(List<RecordInput> recordInputs, Boolean allOrNone){
        List<DMLResult> dmlResults = new List<DMLResult>();

        /**
         * Check if records is null or empty
         */
        if(recordInputs == null || recordInputs.isEmpty()){
            return dmlResults;
        }

        try{
            List<SObject> insertRecords = getSObjectList(recordInputs);

            List<Database.SaveResult> results = Database.insert(insertRecords, allOrNone, AccessLevel.USER_MODE);

            for(Database.SaveResult result : results){
                dmlResults.add(new DMLResult(result));
            }

        }catch(Exception e){
            generateAuraException('Error inserting records, please contact with your admin');
        }
        return dmlResults;
    }

    /**
     * Upsert records (all records must have the same externalId field and it must be the same sObject type)
     * @param recordInputs List of records to upsert
     * @param externalId External Id field name
     * @param allOrNone If true, all records must be upserted successfully or none will be upserted
     */
    @AuraEnabled
    public static List<DMLResult> upsertRecords(List<Object> records, String apiName, String externalId, Boolean allOrNone){
        List<DMLResult> dmlResults = new List<DMLResult>();

        if(String.isBlank(apiName) || String.isBlank(externalId)){
            generateAuraException('apiName and externalId must be provided');
        }
        
        /**
         * Check if records is null or empty
         */
        if(records == null || records.isEmpty()){
            return dmlResults;
        }


        try{
            
            List<SObject> upsertRecords = new List<SObject>();

            for(Object record : records) {
                upsertRecords.add((SObject)JSON.deserialize(JSON.serialize(record), Type.forName(apiName)));
            }

            Schema.sObjectField schemaExternalId = upsertRecords[0].getSObjectType().getDescribe().fields.getMap().get(externalId).getDescribe().getSObjectField();

            List<Database.UpsertResult> results = Database.upsert(upsertRecords, schemaExternalId, allOrNone, AccessLevel.USER_MODE);

            for(Database.UpsertResult result : results){
                dmlResults.add(new DMLResult(result));
            }

        }catch(Exception e){
            generateAuraException('Error upserting records, please contact with your admin');
        }

        return dmlResults;
    }

    public class DMLResult {
        @AuraEnabled
        public Boolean success { get; set; }
        @AuraEnabled
        public String value { get; set; }
        @AuraEnabled
        public String reason { get; set; }

        private void setErrors(List<Database.Error> errors) {
            String errorStr = '';

            for(Database.Error error : errors) {
                if(errorStr != '') {
                    errorStr += ', ';
                }
                errorStr += String.join(error.getFields(), ', ') + ': ' + error.getMessage();
            }

            this.reason = errorStr;
        }

        public DMLResult(Database.SaveResult result) {
            this.success = result.isSuccess();
            this.value = result.getId();
            this.setErrors(result.getErrors());
        }

        public DMLResult(Database.UpsertResult result) {
            this.success = result.isSuccess();
            this.value = result.getId();
            this.setErrors(result.getErrors());
        }

        public DMLResult(Database.DeleteResult result) {
            this.success = result.isSuccess();
            this.value = result.getId();
            this.setErrors(result.getErrors());
        }
    }
}