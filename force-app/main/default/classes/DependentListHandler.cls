public with sharing class DependentListHandler {

    @AuraEnabled(cacheable=false)
    public static void convertStringObjectAndFields(String objectName, String firstField, String secondField, String thirdField){
        
        Schema.SobjectField tokenFirstStage  = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(firstField);
        Schema.SobjectField tokenSecondStage = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(secondField);
        Schema.SobjectField tokenThirdStage  = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(thirdField);
        DependentListHandler.getAllDependentValues(tokenFirstStage, tokenSecondStage, tokenThirdStage);
    }


    public static void getAllDependentValues(Schema.sObjectField tokenFirstStage, Schema.sObjectField tokenSecondStage, Schema.sObjectField tokenThirdStage){

        Map<String, List<String>> dependentPicklistValuesMapCategory = DependentListHandler.getDependentPicklistValues(tokenFirstStage); // Case.Department__c
        List<String> dependentCategory = dependentPicklistValuesMapCategory.get('Servising'); // 'Servising'
        System.debug('CATEGORY SIZE: ' + dependentPicklistValuesMapCategory.size());
        Map<String, List<String>> dependentPicklistValuesMapSubCategory = DependentListHandler.getDependentPicklistValues(tokenThirdStage); // Case.Sub_Category__c

        for(String category : dependentCategory){
            System.debug('CATEGORY::: ' + category);
            List<String> dependentSubCategory = dependentPicklistValuesMapSubCategory.get(category);
            if(dependentSubCategory != null && dependentSubCategory.isEmpty()){
                System.debug('SUB CATEGORY SIZE::: ' + dependentSubCategory.size());
                for(String subCategory : dependentSubCategory){
                  System.debug('****SUB-CATEGORY*** ' + subCategory);
                }    
            }
        }
    }

    public static Map<String, List<String>> getDependentPicklistValues(Schema.sObjectField dependToken) {

        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<String>>();
        }
    
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
    
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }
        return dependentPicklistValues;
    }

    // @AuraEnabled(cacheable=true)
    // public static RecordTypeInfoWrapper getObjectRecordTypes(String objectApiName){

    //     Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectApiName).getDescribe();
    //     Map<String, Schema.RecordTypeInfo> recordTypesMap = objectDescribe.getRecordTypeInfosByName();
    //     RecordTypeInfoWrapper wrapper = new RecordTypeInfoWrapper();
    //     for (String recordTypeName : recordTypesMap.keySet()) {
    //         Schema.RecordTypeInfo recordTypeInfo = recordTypesMap.get(recordTypeName);
    //         String recordTypeId = recordTypeInfo.getRecordTypeId();
    //         Map<String, String> recordTypeMap = new Map<String, String>();
    //         recordTypeMap.put('Id', recordTypeId);
    //         recordTypeMap.put('Name', recordTypeName);
    //         wrapper.recordTypes.add(recordTypeMap);
    //     }
    //     System.debug('wrapper: ' + wrapper);
    //     return wrapper;
    // }

    // public class RecordTypeInfoWrapper {
    //     @AuraEnabled
    //     public List<Map<String, String>> recordTypes { get; set; }

    //     public RecordTypeInfoWrapper() {
    //         recordTypes = new List<Map<String, String>>();
    //     }
    // }


}