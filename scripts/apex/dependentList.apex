//Script to get dependent list
Map<String, List<String>> dependentPicklistValuesMapCategory = DependentListHandler.getDependentPicklistValues(Case.Category__c);
List<String> dependentCategory = dependentPicklistValuesMapCategory.get('Servicing');
System.debug('@@CATEGORY SIZE: ' + dependentPicklistValuesMapCategory.size());
Map<String, List<String>> dependentPicklistValuesMapSubCategory = DependentListHandler.getDependentPicklistValues(Case.Sub_Category__c);

for(String category : dependentCategory){
    System.debug('@@CATEGORY::: ' + category);
    List<String> dependentSubCategory = dependentPicklistValuesMapSubCategory.get(category);
    if(dependentSubCategory != null){
    	System.debug('@@SUB CATEGORY SIZE::: ' + dependentSubCategory.size());
        for(String subCategory : dependentSubCategory){
	      System.debug('****@@SUB-CATEGORY*** ' + subCategory);
		}    
    }
}
