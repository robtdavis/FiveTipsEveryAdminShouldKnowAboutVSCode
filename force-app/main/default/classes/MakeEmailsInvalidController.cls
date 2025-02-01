public with sharing class MakeEmailsInvalidController {
   
    
    @AuraEnabled(cacheable = true)
    public static List<OptionWrapper> fetchAllObjects(){
        List<OptionWrapper> selectOptions = new List<OptionWrapper>();

        for(Schema.SObjectType objectType : Schema.getGlobalDescribe().Values()){
            String apiName = objectType.getDescribe().getName();
            String objLabel = objectType.getDescribe().getLabel();

            selectOptions.add(new OptionWrapper(objLabel, apiName));
        }

        return selectOptions;
    
    }

    public class OptionWrapper {

        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        
        public OptionWrapper( String label, String value ) {
        
            this.label = label;
            this.value = value;
        
        }

    }

    @AuraEnabled
    public static void objectsToAnonymize(List<String> objectNames, String batchSize, Boolean deleteRecords){
 
        for(String obj: objectNames){
            String batchJobId = Database.executeBatch(new MakeEmailsInvalidBatch(obj, deleteRecords), Integer.valueOf(batchSize));
        }
    }

        
}