public with sharing class MakeEmailsInvalidBatch implements Database.Batchable<SObject> {
    
    String objectName;
    Set<String> fieldNames = new Set<String>();
    Boolean deleteUnchangeable;
    Organization sfdcOrg;
    
    public MakeEmailsInvalidBatch(String objectName, Boolean deleteUnchangeable ) {

        this.objectName = objectName;
        this.deleteUnchangeable = deleteUnchangeable;

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if(objectName != null){
            
            List<Schema.DescribeFieldResult> describeFieldResultsList = new List<Schema.DescribeFieldResult>();
            for (Schema.SObjectField sObjectField : objType.getDescribe().fields.getMap().values()){
                describeFieldResultsList.add(sObjectField.getDescribe());
            }
                
            for (Schema.DescribeFieldResult describeFieldResult : describeFieldResultsList){
                if (describeFieldResult.isAccessible() && describeFieldResult.isUpdateable() 
                && describeFieldResult.getType() == Schema.DisplayType.EMAIL){
                    fieldNames.add(describeFieldResult.getName());
                }
            }
        }

        sfdcOrg = [Select Id, IsSandbox, OrganizationType FROM Organization LIMIT 1];
    }

    public Database.QueryLocator start(Database.BatchableContext bc){

        String qry = 'SELECT Id, ';
        String whereClause = ' ';

        if(this.sfdcOrg.IsSandbox == true || this.sfdcOrg.OrganizationType == 'Developer Edition' || Test.isRunningTest()){
            for(String fld: fieldNames){
                qry += fld+', ';
                whereClause += fld+' != null OR ';
            }
            qry = qry.removeEnd(', ');
            whereClause = whereClause.removeEnd(' OR ');
        }

        qry = qry+' FROM '+this.objectName+ ' WHERE '+whereClause;

        return Database.getQueryLocator(qry);
    }
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        for(sObject obj: scope){
            for(String fld: fieldNames){
                if(String.isNotBlank(fld)){
                    obj.put(fld, String.valueOf(obj.get(fld)+'.invalid'));
                } 
            }
        }

        
        List<Database.SaveResult> saveResults = database.update(scope, false);

        List<Id> recordsToDelete = new List<Id>();
        for(Integer i = 0; i < scope.size(); i++) {
            if (!saveResults.get(i).isSuccess()){
                recordsToDelete.add(scope.get(i).Id);
            } 
        }

        if(recordsToDelete.size() > 0 && deleteUnchangeable == true){
            List<Database.DeleteResult> drList = Database.delete(recordsToDelete, true);
        }
        
        System.Debug('recordsToDelete '+recordsToDelete);
    }

    public void finish(Database.BatchableContext BC) {
        
    }
}