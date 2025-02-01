public with sharing class ConfigurablePopUpController {
    
    @AuraEnabled(cacheable=true)
    public static Boolean showModal(String recordId, String objectAPIName, String objectFieldName, String fieldValueToShow){
        Boolean showModal = false;

        String qryStr = 'SELECT '+objectFieldName
                        + ' FROM '+objectAPIName+ ' WHERE Id = :recordId AND '
                        + objectFieldName+' = :fieldValueToShow LIMIT 1';

        try{
            sObject result = Database.query(qryStr);
            showModal = true;
        } catch(Exception e){
            System.Debug('Criteria not matched');
        }

        return showModal;

    }
}